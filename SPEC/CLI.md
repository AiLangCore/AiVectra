# AiVectra CLI Spec

## Scope
This specification defines user-visible CLI behavior only:
- command grammar
- argument forwarding
- path/cwd project inference
- exit semantics

It does not define host/runtime implementation details.

## Commands
`aivectra` supports:
- `run <app-or-project> [app-args...]`
- `debug run [debug-options] [app-or-project] [-- app-args...]`
- `debug trace run [debug-options] [app-or-project] [-- app-args...]`
- `debug capture run [debug-options] [app-or-project] [-- app-args...]`
- `debug scenario <fixture.toml> [--name <scenario>]`
- `input --window "<title>" --events "<tokens>" [--delay-ms N] [--dry-run]`
- `icon <project-path> [label]`

## Debug Grammar
Accepted forms:
- `aivectra debug run --debug-mode <live|snapshot|replay|scene> <target> [-- app-args...]`
- `aivectra debug run --debug-mode=<live|snapshot|replay|scene> <target> [-- app-args...]`
- `aivectra debug trace run <target> [-- app-args...]`
- `aivectra debug capture run <target> [--out <dir>] [-- app-args...]`
- `aivectra debug scenario <fixture.toml> [--name <scenario>]`

Legacy compatibility form remains valid:
- `aivectra debug <live|snapshot|replay|scene> <target> [app-args...]`
- `aivectra debug [debug-options] <target> [-- app-args...]`

`--` is the required forwarding boundary for app arguments in canonical form.

## Path And CWD Inference
- If `target` is a directory and contains `app.aibc1`, target resolves to `app.aibc1`.
- Else, if `target` contains `Src/app.aos`, target resolves to that app entry file.
- If `debug` is invoked without explicit target, and cwd contains `project.aiproj`, cwd project is used.
- Absolute and relative paths are accepted.

## Argument Forwarding
- Arguments after `--` are forwarded to the app unchanged.
- Wrapper/debug options are parsed only before `--`.

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
