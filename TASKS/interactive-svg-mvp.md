# AiVectra Interactive SVG MVP

## Goal
Implement a deterministic, declarative, SVG-inspired interactive foundation for AiVectra with minimal controls and minimal filter support.

## Constraints
- Full tree recompute on every event
- No retained widget tree
- No lifecycle hooks
- No CSS/DOM
- No animation system
- Deterministic behavior across runs

## Checklist
- [x] Scene model implemented: `Rect`, `Ellipse`, `Path`, `Text`, transform helpers (translation)
- [x] Deterministic hit testing implemented (`Rect`, `Ellipse`, `Path-bounds`) using reverse render order in sample routing
- [ ] Fill rule documented and implemented for path hit testing
- [ ] Pointer events implemented: down/up (+ move optional), synthetic click
- [x] Single-focus model implemented (click input to focus, click-away clears)
- [x] Keyboard routing implemented to focused node only
- [ ] Interactive identity model enforced (`id` required for interactive nodes)
- [x] Button control implemented with multiple visual states
- [x] Minimal TextField control implemented (single-line, caret, insert/backspace/left/right)
- [x] Transform support implemented (minimum: translation)
- [x] Gradient support implemented (minimum linear gradient)
- [x] Minimal filter support implemented: gaussian blur
- [x] Sample(s) updated to demonstrate overlapping-hit correctness and controls
- [x] Golden outputs added for deterministic regression checks
- [x] Validation scripts updated for repeatable checks

## Notes
- Gaussian blur is implemented in AiLang as a deterministic multi-band software approximation (`drawGaussianBlurRect`), without host-side filter syscall dependency.
- Path hit testing is currently MVP bounding-box semantics (`pointInPathBounds`), not full even-odd point-in-path parsing.

## Acceptance
- Topmost overlapping shape receives click
- Button visibly changes state and fires click callback deterministically
- TextField supports typing, backspace, caret movement
- Deterministic output for snapshot/replay tests
