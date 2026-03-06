# AiVectra v0.0.1 Roadmap

## Purpose
- This document records current status, the target state for `v0.0.1`, and the immediate path after `v0.0.1`.
- It is a planning document, not a normative runtime spec.

## Direction
- AiVectra is an AI-first, deterministic, vector-based cross-platform GUI system.
- The portable UI model is an interactive vector scene graph, conceptually similar to SVG plus canonical events and semantic state.
- The application model is application-first and surface-based, not widget-first and not desktop-window-first.

## Current Status

### Portable Runtime
- Partial runtime exists in `src/AiVectra/src/lib.aos`.
- The library currently contains a single-window loop model.
- Runtime and spec are not yet fully converged:
  - `SPEC/APP_RUNTIME.md` describes a hook-based runtime contract.
  - samples and exports are still mid-transition.

### Samples
- `HelloWorld` is the intended canonical baseline.
- Other samples still use older direct-loop or direct-syscall patterns.
- Sample conformance is incomplete.

### Target Scaffolding
- `./scripts/aivectra init` and `targets add` scaffold these targets today:
  - `apple-macos`
  - `windows`
  - `linux`
  - `wasm-spa`
  - `wasm-fullstack`
- Sample target metadata exists today under `samples/HelloWorld/Targets`.
- macOS currently has the most concrete packaging/publish handling.
- Windows, Linux, and WASM targets are scaffolded but not yet fully productized.

### Missing Platform Work
- No canonical multi-surface runtime yet.
- No explicit `HostCapabilities` model yet.
- No iOS or Android target scaffolding yet.
- No watch, TV, or car target profiles yet.
- No Linux bootable GUI target profile yet.
- No X server / remote GUI host profile yet.
- Native wrapping policy exists conceptually, but not yet as a fully written target binding spec.

## v0.0.1 Goal
- Deliver one portable AiVectra application model with a small, real, shippable target set.

### v0.0.1 Supported Targets
- macOS app
- Windows app
- Linux desktop app
- X server / remote GUI host profile
- Linux bootable kernel + GUI profile
- WASM SPA
- WASM fullstack

### Post-v0.0.1 Near-Term Targets
- iOS
- Android

## Core Architecture For v0.0.1

### Semantic Model
- One application semantic authority.
- One serialized semantic event stream.
- One main semantic task.
- Zero or more worker tasks.
- Only the main semantic task mutates application state.
- Workers perform mechanical work only and report results through canonical events.

### Portable UI Model
- Application-first.
- Surface-based.
- Interactive vector scene graph.
- Explicit state-driven rendering.
- Explicit events and focus.
- Reusable scene definitions and instances.
- No built-in widget primitives.

### Host Model
- Hosts are mechanical.
- Hosts map portable surfaces to native containers.
- Hosts translate native input and lifecycle events into canonical app events.
- Hosts must not define application semantics.

## Runtime Destination
- The portable runtime contract should converge toward:
  - `appInit(args) -> state`
  - `appUpdate(state, event) -> { state, effects }`
  - `appRender(state) -> appView`
- `appView` should describe the whole application.
- `appView` should contain one or more surfaces.
- Each surface should contain an interactive vector scene.

## Capability Model
- AiVectra must support one semantic model across many capability profiles.
- Small targets and large targets must share the same application model.
- Capability differences should be explicit rather than implicit.

### Capabilities To Model
- render capabilities
- input capabilities
- concurrency capabilities
- native binding capabilities
- packaging and deployment capabilities

## Native Integration Model
- Generic non-UI native integration belongs at the AiVM syscall boundary.
- UI-specific native integration belongs to AiVectra.
- Target-specific wrappers and packaging glue belong under `Targets/`.
- Wrapped native libraries must expose minimal, explicit, mechanical boundaries.
- Host wrappers must not become alternate semantic runtimes.

## Diagnostics Policy
- Non-working code must fail loudly, specifically, and deterministically.
- Stubs and placeholder implementations must raise explicit runtime exceptions.
- Target-unavailable features should emit compile-time or build-time warnings when detectable ahead of execution.
- If execution still reaches a target-unavailable path, runtime must raise an explicit not-supported exception.
- Silent failure, silent no-op behavior, and fake success are out of scope for `v0.0.1`.

## Compliance Work Needed Before v0.0.1

### Runtime And Sample Compliance
- Export and stabilize the canonical runtime public API.
- Refactor `HelloWorld` to use the canonical hook-based runtime path.
- Move samples away from direct loop ownership where possible.
- Keep sample code free of direct `sys.*` calls after bootstrap.

### Layout And Template Compliance
- Make canonical app structure consistent:
  - `Src/`
  - `Assets/icons/`
  - `Targets/...`
- Make `./scripts/aivectra init` emit that canonical structure.
- Keep wrapper resolution compatible with both legacy `src/` apps and canonical `Src/` apps during transition.

### Target Definition Work
- Define support tiers:
  - Tier 1: shippable in `v0.0.1`
  - Tier 2: immediate post-`v0.0.1`
  - Tier 3: longer-horizon ecosystem targets
- Separate scaffolded targets from fully supported targets in docs and tooling.

## Suggested Support Tiers

### Tier 1
- `apple-macos`
- `windows`
- `linux`
- `wasm-spa`
- `wasm-fullstack`

### Tier 2
- `ios`
- `android`

### Tier 3
- `watch`
- `tv`
- `car`
- `xserve`
- `linux-bootable-gui`
- embedded targets

## Exit Criteria For v0.0.1
- Canonical runtime contract documented and implemented for baseline samples.
- `HelloWorld` is a real conformance sample.
- `./scripts/aivectra init` emits canonical layout.
- Tier 1 targets are clearly classified as supported, experimental, or scaffold-only.
- Packaging and publish flow is documented for supported targets.
- Capability and target-boundary rules are written clearly enough that AI agents can extend the system without violating architecture.
