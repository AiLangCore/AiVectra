# AiVectra Specification Index

Status: normative index for AiVectra UI runtime and rendering contracts.

The normative AiVectra specification consists of:

- `RENDERING.md`
- `VISUAL_CONTRACT.md`
- `THREADING.md`
- `APP_STRUCTURE.md`
- `CLI.md`
- `STYLE_AIVECTRA.md`

`STYLE_AILANG.md` is a local pointer to the canonical AiLang source-style
specification and is not a duplicate AiVectra-owned contract.

## Ownership Boundary

AiLang owns language meaning, application evaluation semantics, state-transition
semantics, validation, formatting, and bytecode meaning.

AiVM owns runtime mechanics, deterministic event-queue mechanics, worker
scheduling mechanics, syscall dispatch, memory mechanics, and host ABI behavior.

AiVectra owns:

- vector scene representation and rendering contracts
- UI event translation
- scene graph mutation rules
- deterministic layout and paint policy
- visual conformance artifacts
- UI/runtime integration with AiLang and AiVM
- AiVectra CLI and canonical app-layout contracts

AiVectra must not redefine AiLang language semantics or AiVM runtime mechanics.
Platform hosts are mechanical render/input adapters and must not introduce
observable behavior absent from the applicable specifications.

## Authority Rule

If implementation, `Docs/`, `Design/`, `Planning/`, `Archive/`, examples,
goldens, issue templates, or agent instructions conflict with the normative
specification files listed above, the listed specification files win for
AiVectra-owned behavior.

Golden visual tests are conformance evidence. They must not silently define new
behavior without matching specification updates.

## Change Control

A change affecting vector scene output, layout, paint order, event translation,
thread integration, visual artifacts, CLI behavior, or canonical app layout must
update the applicable normative specification first, then goldens/tests, then
implementation.
