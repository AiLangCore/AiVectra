# AiVectra Style Guide

## Prime Directive
- AiVectra is AI-first.
- The engine, runtime, samples, and packaging model must be optimized for AI agents as the primary authors and operators.
- If a design helps human familiarity but reduces determinism, explicitness, or agent operability, reject it.

## Purpose
- This guide defines the canonical authoring style for AiVectra-facing app code, runtime code, and samples.
- It complements architectural rules in `AGENTS.md` and the normative behavior specs.

## AI-First Rules
- Prefer explicit contracts over convention hidden in prose.
- Prefer a small number of canonical patterns over many equivalent styles.
- Make runtime boundaries obvious.
- Keep naming, file layout, and app structure stable across samples and templates.
- Optimize for safe AI modification, diffability, and automated validation.

## Capitalization Rules
- Capitalization must carry structural meaning.
- Use `PascalCase` for top-level structural directories and major platform grouping directories: `Src`, `Assets`, `Targets`, `Apple`, `Microsoft`, `Linux`, `Web`.
- Use lowercase for concrete asset buckets and web roots: `bundle`, `icons`, `splash`, `images`, `fonts`, `locale`, `www`.
- Use `PascalCase` for product and library names: `AiVectra`, `AiLang`, `AiVM`.
- Use `camelCase` for runtime hooks, helper names, node ids when encoded as symbols, and app-level state fields.
- Do not use capitalization decoratively.
- Do not mix case variants for the same role such as `Icons` and `icons`.

## Runtime Ownership
- AiVectra owns UI mechanics.
- App code owns state and pure behavior.
- Host code is mechanical only.
- There must be one obvious runtime path for window creation, event delivery, rendering, and shutdown.

## App Shape
- Canonical app modules should expose a small, standard surface:
  - `appInit`
  - `appRender`
  - `appUpdate`
  - `start`
- Samples should consume the public runtime rather than re-implementing loop mechanics.
- Direct `sys.*` usage in sample code is only acceptable at explicitly allowed bootstrap boundaries until the runtime is fully converged.

## Scene Authoring
- Compose UI from vector primitives only.
- Keep scene structure explicit and deterministic.
- Prefer stable node ids and target ids.
- Derive visual state from app state, not from hidden host state.
- Keep render code declarative: calculate values, then emit primitives.

## Interaction
- Input handling must be explicit and state-driven.
- Focus is part of app-visible semantic state or canonical runtime state, never an invisible host-only concept.
- Keyboard and pointer logic should target explicit ids and hit regions.
- Do not introduce widget abstractions into the engine.

## Windows
- Treat windows as explicit runtime-managed UI surfaces.
- Window lifecycle must remain under AiVectra runtime control.
- Multi-window support, when added, must route through canonical app/runtime contracts rather than ad hoc sample loops.
- Do not encode app semantics in native window manager behavior.

## Menus, Tray, Dock, Taskbar
- These are host integration surfaces, not semantic authorities.
- Their meaning must be converted into canonical AiLang/AiVectra events.
- Do not put business logic in platform menu callbacks.
- Do not let platform-specific affordances create divergent semantic behavior.

## Samples
- Samples exist to demonstrate capability, not to accumulate framework debt.
- Each sample should have one clear purpose.
- Keep sample architecture minimal and canonical.
- Avoid hacks that bypass missing engine features.
- Prefer AiLang stdlib helpers for parsing and normalization before introducing sample-local utility code.
- If a sample needs a missing capability, stop and specify the capability instead.

## Packaging And Layout
- Prefer one canonical app layout.
- Prefer one canonical icon source: `Assets/icons/app.svg`.
- Prefer generated target artifacts over committed platform-specific output files where possible.
- `project.aiproj` should be the source of truth for identity and packaging metadata.

## Debugging
- Debug tooling belongs in AiVectra engine code or the CLI.
- Keep debug outputs generic and reusable across apps.
- Samples may invoke debug APIs but must not define bespoke debug protocols.

## Diagnostics And Failure
- Stubs, placeholders, and unimplemented runtime paths must fail explicitly at runtime.
- Target-specific unavailable features should emit a compiler or build warning when detectable before execution.
- If an unavailable path is still executed, runtime must raise an explicit not-supported exception.
- AiVectra must never silently ignore unsupported behavior or silently pretend a feature worked.

## Forbidden Style
- Independent UI event loops outside canonical runtime ownership.
- Hidden timers or animation loops.
- Engine-level widget abstractions.
- Host-defined UI semantics.
- Platform-specific hacks in samples.
- Multiple competing app layouts or runtime idioms.

## Canonical Goal
- An AI agent should be able to inspect any AiVectra app and quickly answer:
  - what the runtime owns
  - what the app owns
  - how input becomes semantic events
  - how state becomes vector scene output
  - how packaging maps from one canonical project layout
