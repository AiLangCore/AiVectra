# AiVectra Docs

## Objective

Provide stable usage documentation for humans and developer agents using,
testing, packaging, and integrating AiVectra.

## Normative Source

- `../SPEC/README.md`
- `../SPEC/RENDERING.md`
- `../SPEC/VISUAL_CONTRACT.md`
- `../SPEC/THREADING.md`
- `../SPEC/APP_STRUCTURE.md`
- `../SPEC/CLI.md`
- `../SPEC/STYLE_AIVECTRA.md`

If a document in `Docs/` conflicts with `SPEC/`, follow `SPEC/`.

## Taxonomy

- `../SPEC/` contains normative AiVectra UI/runtime specifications.
- `../Docs/` contains stable usage documentation for humans and developer agents.
- `../Design/` contains non-normative design notes, proposals, rationale, and decisions.
- `../Planning/` contains gated plans, tasks, readiness notes, and checklists.
- `../Archive/` contains historical or superseded documents.
- `*.local.md` and `*.local.*` files are local scratch and must not be committed.

If a planning or design document proposes behavior that becomes scene, layout,
paint, input, threading, CLI, app-layout, or visual-contract behavior, move that
behavior into `../SPEC/` before implementation relies on it.

## Primary Usage Entry Points

- Repository usage and local commands: `../README.md`
- Contributor setup: `../CONTRIBUTING.md`
- CLI behavior contract: `../SPEC/CLI.md`
- Canonical app layout: `../SPEC/APP_STRUCTURE.md`
- Visual testing contract: `../SPEC/VISUAL_CONTRACT.md`

## Related Non-Usage Documents

- [Specification Index](../SPEC/README.md)
- [Design Notes](../Design/README.md)
- [Planning Documents](../Planning/README.md)
- [Archive](../Archive/README.md)
