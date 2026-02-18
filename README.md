# AiVectra

![AiVectra](Assets/AiVectra.png)

AiVectra is the vector-based user interface system for AiLang.

It provides deterministic, resolution-independent rendering across platforms while preserving AiLang’s semantic authority.

AiVectra does not define language behavior.
It renders it.

---

## Purpose

AiVectra enables portable GUI applications for:

- macOS
- Linux
- iOS
- Android
- Web
- Embedded targets (future)

All UI is defined using vector primitives and layout constructs governed by AiLang.

---

## Core Principles

### 1. Vector First

All UI elements are defined as scalable vector primitives.

No raster-first assumptions.
No fixed-resolution layouts.

Rendering must be resolution-independent.

---

### 2. Deterministic Layout

Layout behavior must be:

- Predictable
- Canonical
- Spec-governed
- Testable via golden outputs

If layout behavior changes:
1. Update spec
2. Update golden tests
3. Then update implementation

Never the reverse.

---

### 3. Semantic Authority Lives in AiLang

AiVectra does not:

- Define UI behavior
- Interpret application logic
- Introduce host-specific semantics

UI structure, state transitions, and rendering rules are defined in AiLang.

AiVectra executes rendering instructions.

---

### 4. Host Is Mechanical

Platform renderers:

- Translate vector instructions to native surfaces
- Provide input events
- Provide surface lifecycle management

They must not introduce behavior not described in spec.

The host is replaceable.

---

## Architecture Overview

AiLang Application
        ↓
AiLang Evaluator
        ↓
Vector Scene Graph (AiVectra)
        ↓
Platform Renderer (mechanical)
        ↓
Native Surface

AiVectra operates as a deterministic vector scene system.

---

## Rendering Model

AiVectra is designed as:

- Retained-mode scene graph
- Deterministic layout pass
- Deterministic paint pass
- Canonical ordering rules

No implicit z-index behavior.
No platform-dependent layout differences.
No hidden measurement passes.

All rendering must be reproducible.

---

## Scope (Current)

- Vector primitives (path, rect, circle, text)
- Deterministic layout model
- Scene graph structure
- Platform abstraction layer

Not in scope:

- Animation systems (initially)
- GPU optimization passes
- Styling engines beyond spec definition
- Platform-specific visual effects

Stability over feature velocity.

---

## Relationship to AiLang

AiLang defines:

- UI structure
- Component composition
- State transitions
- Layout rules
- Rendering instructions

AiVectra renders those instructions.

The runtime is an implementation detail.
The spec is authoritative.

---

## Status

Early architecture phase.

Current focus:

- Scene graph design
- Layout determinism
- Platform abstraction boundary
- Golden test strategy

---

## Project Layout

This repository is initialized as an **AiLang workspace** with five projects:

- `src/AiVectra/project.aiproj` - AiVectra library manifest
- `src/AiVectra.Cli/project.aiproj` - AiVectra CLI manifest
- `samples/HelloWorld/project.aiproj` - hello-world window sample app
- `samples/HelloName/project.aiproj` - hello-name window sample app
- `samples/InteractiveSvgMvp/project.aiproj` - interactive SVG MVP sample app
- `src/AiVectra/src/lib.aos` - library exports (`library`, `version`, `rect`, `circle`, `text`, `label`, `window`, `helloWindow`, `helloNamedWindow`, `waitForClose`)
- `examples/golden/ui-components/*` - golden output fixtures for UI component behavior

---

## Local Run

Use `airun` from your normal toolchain (`PATH`).  
If you have a temporary local binary in this repo, replace `airun` with `./.tools/airun`.

Run the sample app from repo root:

`airun run ./samples/HelloWorld/src/app.aos`

Run the named greeting example:

`airun run ./samples/HelloName/`

`HelloName` uses GUI text entry from key events and a clickable `Submit` button to switch to the greeting view.

Wrapper/CLI:

- `./scripts/aivectra` is a thin wrapper over `airun` (no project-specific default).
- Override runtime location with env or flag:
  - `AIRUN_BIN=/path/to/airun ./scripts/aivectra`
  - `./scripts/aivectra --airun /path/to/airun`
- Example:
  - `./scripts/aivectra run ./samples/HelloWorld/`
  - `./scripts/aivectra run ./samples/InteractiveSvgMvp/`
  - `./scripts/aivectra icon ./samples/HelloWorld/`
- Debug tooling via AiLang CLI project (`src/AiVectra.Cli`):
  - `./scripts/aivectra run ./src/AiVectra.Cli/ debug snapshot`
  - `./scripts/aivectra run ./src/AiVectra.Cli/ debug replay`
  - `./scripts/aivectra run ./samples/HelloName/`
- Golden checks:
  - `./scripts/test-golden-ui.sh`
  - `./scripts/test-interactive-svg-mvp.sh`
  - `./scripts/test-screenshot-debug-reality.sh` (requires macOS Screen Recording permission)
- Compatibility wrapper:
  - `./scripts/ui-debug.sh snapshot`
  - `./scripts/ui-debug.sh replay`
  - `./scripts/ui-debug.sh live`

App icon generation:

- Standard command: `./scripts/aivectra icon <project-path>`
- Optional label override: `./scripts/aivectra icon <project-path> <label>`
- Output:
  - `<project-path>/Assets/AppIcon/appicon.svg`
  - `<project-path>/Assets/AppIcon/manifest.txt`

Run the library project directly (sanity check):

`airun run ./src/AiVectra/src/lib.aos`

Windowed hello world baseline:

- `helloWindow()` creates a host window, draws the hello frame via `sys.ui_*`, presents it, then closes it.
- `helloNamedWindow(name)` creates a host window and renders `Hello {name}!`.
- `waitForClose(windowHandle)` blocks until `sys.ui_pollEvent` reports `type="closed"`.
- `window(title)` creates a window handle via `sys.ui_createWindow`.
- `rect(windowHandle)` and `text(windowHandle)` emit real draw calls.

---

## Philosophy

Resolution-independent.
Deterministic.
Spec-governed.
Replaceable host.
No semantic leakage.

---

AiVectra — deterministic vector UI for AiLang.
