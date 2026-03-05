# AiVectra Local TODO

## 1. Canonical App Structure
- [ ] Write `SPEC/APP_STRUCTURE.md` with finalized tree:
  - `project.aiproj`
  - `AGENTS.md`
  - `README.md`
  - `Src/`
  - `Assets/Bundle`, `Assets/Icons`, `Assets/Splash`, `Assets/Fonts`, `Assets/Images`, `Assets/Locale`
  - `Targets/Apple/Mac`, `Targets/Microsoft/Windows`, `Targets/Linux`, `Targets/Web/www`, `Targets/Web/WasmSpa/www`, `Targets/Web/WasmFullStack/www`
  - `.toolchain/` (generated, gitignored)

## 2. Lifecycle Standard
- [ ] Write `SPEC/APP_RUNTIME.md` for standardized app entry/runtime:
  - one AiVectra app runtime module owns main loop and event pump
  - app provides hooks for initial state/render/update
  - worker integration contract (UI thread semantic authority, worker messages serialized via queue)

## 3. HelloWorld As Canonical Baseline
- [ ] Refactor `/samples/HelloWorld` to match canonical structure (use `Src/` path and agreed Assets/Targets layout).
- [ ] Ensure sample uses AiVectra public API only (no direct `sys.*` in sample).
- [ ] Keep behavior minimal: displays "Hello World" in window/page.

## 4. Init Template
- [ ] Update `scripts/aivectra init` to generate exactly the canonical app structure.
- [ ] Extend `project.aiproj` metadata as source-of-truth (app id, name, version, targets).
- [ ] Generate platform files from TOML templates at build time into `dist/`.

## 5. CI / Policy Enforcement
- [ ] Keep/extend no-direct-syscall check for samples/apps after bootstrap.
- [ ] Add template conformance check for `aivectra init` output.
- [ ] Add smoke test: initialize app -> run host target -> exits cleanly on close.

## 6. Cleanup / Consistency
- [ ] Remove stale layout variants (`src/`, `Assets/AppIcon`, mixed-case `icons`) from canonical sample/template.
- [ ] Ensure docs/readme use the same naming (`Src`, `www`, `Bundle`) everywhere.
