# AiVectra Design Notes

Status: non-normative.

This directory contains architecture notes, proposals, rationale, experiments,
and accepted design decisions for AiVectra.

Design documents do not define AiLang language semantics, AiVM runtime mechanics,
or AiVectra runtime/rendering contracts. If a design becomes authoritative
scene, layout, paint, event, threading, CLI, app-layout, or visual behavior, move
the contract into `../SPEC/` before implementation relies on it.

## Filename Classes

- `*.feature-<name>.md` - active feature design or proposal.
- `*.decision.md` - accepted architectural decision record.
- `*.note.md` - shared developer note or rationale.
- `*.experiment.md` - exploratory UI/runtime work.

Every design document should state whether it is proposed, accepted, or
historical.
