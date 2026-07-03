# AiVectra Beta Readiness

Status: alpha to early beta.

AiVectra has beta packaging, libraries, tools, templates, and useful fixtures,
but product maturity should still be described honestly as alpha/early beta
until the supported UI MVP is frozen and tested. This file defines the minimum
honest beta bar for outside developers, conference demos, and sponsor review.

## Current Position

- Current public package/release: `v0.0.1-beta.2`
- Current branch for integration work: `develop`
- AiVectra owns vector UI library semantics, UI tooling, templates, test fixtures,
  platform renderer integration, and app/debug artifacts.
- AiLang owns language semantics. AiVM owns runtime mechanics and syscalls.

## Already Present

- [x] Public beta package exists.
- [x] Library, tool, and template package content exists.
- [x] Public sample apps moved to the sibling `ailang-examples` repository.
- [x] WeatherApp exercises real package restore, storage, HTTP, AiSVG, desktop,
  WASM, Linux target, and AiOS target paths as the current production-style
  sample.
- [x] Supported fixture app structure is validated by CI-facing tests.
- [x] Supported deterministic fixture run modes pass locally.
- [x] Vector-first direction is documented.
- [x] Determinism and semantic-authority rules are documented.
- [x] Platform renderer boundary is defined as mechanical.
- [x] CLI/debug/test scripts exist.
- [x] Input injection tooling exists.
- [x] Cross-platform target ownership moved to target packages/repositories;
  AiVectra remains UI semantics and target adapter surface, not target
  packaging owner.

## Beta Gates

- [x] Define a platform support matrix for macOS, Linux, Windows, Web, iOS,
  and Android.
- [x] Separate "supported now" platforms from planned/future platforms.
- [ ] Freeze the MVP primitive set in `SPEC/`.
- [ ] Freeze the MVP layout model in `SPEC/`.
- [ ] Freeze the MVP event model in `SPEC/`.
- [ ] Define canonical visual/layout golden artifact format.
- [ ] Add mandatory deterministic layout/visual artifact tests in CI.
- [ ] Add event replay tests in CI.
- [ ] Mark screenshot tests optional where OS permissions are required, while
  keeping deterministic artifact tests mandatory.
- [x] Promote WeatherApp from deferred sample to active production-style
  integration sample.
- [ ] Add one realistic CRUD/data-entry sample.
- [ ] Add documentation for writing an AiVectra app from scratch.
- [ ] Add documentation for debugging UI with captured artifacts.
- [ ] Make host renderer non-semantic boundaries testable.
- [ ] Complete AiOS DRM/KMS backend or explicitly mark framebuffer as the only
  supported AiOS GUI backend for the next release.
- [ ] Decide whether Linux X11 under QEMU is release-demo supported or
  experimental for the next release.

## MVP Primitive Decision

Before AiVectra is promoted beyond early beta, decide and document whether the
MVP supports each primitive:

- [ ] Rect
- [x] Path
- [ ] Circle
- [ ] Text
- [ ] Group
- [ ] Image
- [x] Polygon
- [x] AiSVG `use`
- [x] AiSVG `animate`

## MVP Event Decision

Before AiVectra is promoted beyond early beta, decide and document whether the
MVP supports each event type:

- [x] Click/tap
- [x] Key
- [x] Text input
- [ ] Close/window lifecycle
- [x] Pointer/mouse movement as standard input data
- [ ] Scroll/drag semantics with performance and clipping guarantees

## Scope Discipline

- Avoid adding styling, animation, and platform expansion until layout, event,
  rendering, and debug artifact MVP behavior is stable.
- If a feature is semantic, document it in AiVectra specs and test it through
  deterministic artifacts.
- If a feature is platform-mechanical, keep it behind the renderer boundary and
  prove that it does not change semantic state.

## Beta Promotion Rule

AiVectra may be marketed as beta only for the platforms and primitives listed
as supported. Everything else must be labeled planned, experimental, or
deferred.
