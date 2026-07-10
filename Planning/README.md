# AiVectra Planning Documents

Status: non-normative active work tracking.

This directory contains gated feature plans, release-readiness checklists,
migration plans, milestones, and hardening tasks.

Planning documents do not define AiVectra behavior. If a planning item becomes
authoritative scene, layout, paint, event, threading, CLI, app-layout, or visual
behavior, move the contract into `../SPEC/` before implementation relies on it.

## Filename Classes

- `*.feature-<name>.md` - active feature plan.
- `*.rc1.md`, `*.rc2.md`, ... - release-candidate gate.
- `*.milestone-<name>.md` - milestone gate.
- `*.note.md` - shared developer planning note.

Planning documents should identify status, scope, exit criteria, and validation
commands when applicable.
