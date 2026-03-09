# AiVectra CLI Spec

## Scope
This specification defines user-visible CLI behavior only:
- command grammar
- argument forwarding
- path/cwd project inference
- option syntax
- exit semantics

It does not define host/runtime implementation details.

## Canonical Grammar
AiVectra CLI uses a recursive command grammar with indefinite subcommand depth:

- `aivectra [command-args...] [subcommands] [subcommand-args...] ... [project-path] [--] [app-args...]`

Resolution rules:
- command and subcommand parsing happens first
- if an explicit `project-path` is present, use it
- if `project-path` is absent, resolve the project from the current working directory
- after the project is resolved, remaining trailing tokens are `app-args`
- `--` forces all following tokens to be treated as `app-args`
- if no ambiguity exists, trailing tokens after the resolved project may be treated as `app-args` without requiring `--`

Canonical examples:
- `aivectra run`
- `aivectra debug`
- `aivectra run ./samples/WeatherApp`
- `aivectra debug ./samples/WeatherApp events`
- `aivectra debug ./samples/WeatherApp -- events`
- `aivectra debug trace run ./samples/HttpProbe -- events`

## Commands
`aivectra` supports command chains including:
- `run [project-path] [-- app-args...]`
- `debug [project-path] [-- app-args...]`
- `debug run [debug-options] [project-path] [-- app-args...]`
- `debug trace run [debug-options] [project-path] [-- app-args...]`
- `debug capture run [debug-options] [project-path] [-- app-args...]`
- `debug scenario <fixture.toml> [--name <scenario>]`
- `input --window "<title>" --events "<tokens>" [--delay-ms N] [--dry-run]`
- `icon [project-path] [label]`

## Debug Grammar
Accepted forms:
- `aivectra debug run --debug-mode <live|snapshot|replay|scene> [project-path] [-- app-args...]`
- `aivectra debug run --debug-mode=<live|snapshot|replay|scene> [project-path] [-- app-args...]`
- `aivectra debug trace run [project-path] [-- app-args...]`
- `aivectra debug capture run [project-path] [--out <dir>] [-- app-args...]`
- `aivectra debug scenario <fixture.toml> [--name <scenario>]`

Legacy compatibility form remains valid:
- `aivectra debug <live|snapshot|replay|scene> [project-path] [app-args...]`
- `aivectra debug [debug-options] [project-path] [-- app-args...]`

`--` is the explicit forwarding boundary for app arguments in canonical form and should be used whenever there is any parse ambiguity.

## Option Syntax
Canonical AiVectra CLI option forms are:
- long option: `--full-name`
- short option: `-f`

AiVectra CLI must not treat Windows-style slash options as canonical syntax.

Rules:
- `--full-name` is the portable, preferred form
- `-f` is allowed for explicitly documented short aliases
- `/flag` is not canonical AiVectra CLI syntax
- if a generated application on a Windows target chooses to expose Windows-native `/flag` forms, that is target/application behavior, not the AiVectra CLI contract

## Path And CWD Inference
- If `project-path` is a directory and contains `app.aibc1`, target resolves to `app.aibc1`.
- Else, if `project-path` contains `project.aiproj`, cwd/project resolution uses that project directory.
- Else, if `project-path` contains `Src/app.aos`, target resolves to that app entry file.
- If `run` or `debug` is invoked without explicit `project-path`, and cwd contains `project.aiproj`, cwd project is used.
- Absolute and relative paths are accepted.

## Argument Forwarding
- Arguments after `--` are forwarded to the app unchanged.
- If `project-path` is resolved and no ambiguity exists, trailing tokens may be forwarded as `app-args` without `--`.
- Command/debug options are parsed only before `--`.

## Exit Semantics
- Success returns exit code `0`.
- Wrapper argument/path usage failures return exit code `2`.
- Underlying runtime/app failures propagate non-zero exit codes.

## Stable Error Surface
The following are treated as stable for conformance:
- Missing source target:
  - `Err#err1(code=RUN002 message="Source file not found." nodeId=source)`
  - or (native build-path error shape):
    - `Err#err1(code=RUN001 message="Native build failed: could not resolve source .aos from input" nodeId=build)`
  - exit code `2`
- Missing debug target when cwd has no project:
  - message starts with `missing app path for debug command`
  - exit code `2`
- Unknown debug option:
  - message starts with `unknown debug option:`
  - exit code `2`
- Native-c source guard:
  - `Err#err1(code=AIV001 message="Current runtime requires prebuilt .aibc1 input for this project. Build/publish app.aibc1 and re-run." nodeId=program)`
  - exit code `2`

## Adapter Boundary (Process/Path)
Process/path behavior is isolated behind one abstraction seam in `src/AiVectra.Cli/src/runtime_adapter.aos`.
Planned API shape is 1:1 with runtime syscall contract:
- `processStart(command,args,cwd)`
- `processPoll(handle)`
- `processWait(handle)`
- `processRead(handle,stream,maxBytes)`
- `processKill(handle)`
- `pathAbspath(path)`
- `processCwd()`

Parser/command routing layers must not implement subprocess logic directly.
