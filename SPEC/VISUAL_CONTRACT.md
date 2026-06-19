# Visual Contract

## Purpose

AiVectra exists so an AI agent and a human can reason about the same UI.

The agent-facing output is a deterministic visual artifact: scene records,
debug bundles, generated SVG, and golden render data. The human-facing output
is the platform renderer showing the same scene. A passing AiVectra build must
prove those two views describe the same image.

## Contract

- AiLang application state produces an AiVectra scene.
- The scene is deterministic for a given program, input event stream, target,
  viewport, and font/rendering profile.
- Agent tools consume the scene/debug artifact as the canonical mental image.
- Host renderers consume the same scene contract for the human-visible image.
- Tests compare canonical scene output, generated render artifacts, and
  platform screenshots where the host supports screenshot capture.

## Test Layers

- `scripts/doctor.sh` checks environment readiness only.
- `scripts/test-cli-contract.sh` checks command grammar, path resolution,
  argument forwarding, and exit behavior.
- `scripts/test-golden-ui.sh` checks deterministic visual contract output
  against committed goldens.
- `scripts/test-screenshot-debug-reality.sh` checks that a human-visible
  platform window matches the deterministic debug/render contract.
- `scripts/test-all.sh` runs the functional suite. Set
  `AIVECTRA_SCREENSHOT_TEST=1` to include host screenshot parity.
- Host screenshot parity requires a capture helper. Set
  `AIVECTRA_SCREENSHOT_TOOL=/path/to/take_screenshot.py`, or install the Codex
  screenshot skill under `$CODEX_HOME/skills/screenshot`.
- Set `AIVECTRA_ARCHITECTURE_TEST=1` to include architectural lint checks that
  reject direct sample syscalls. Current migration work still needs samples
  rewritten to the public AiVectra API before that lint can be required by
  default.

## Rules

- Do not use a no-window mode as a substitute for visual validation.
- No-window modes are valid only when they emit deterministic scene/debug
  artifacts that can be compared or rendered.
- UI samples should remain real UI samples. If a sample supports `snapshot`,
  `scene`, or `replay`, those modes must emit meaningful visual contract data.
- Runtime errors in visual contract tests are failures, not skips.
- Scroll viewport content must not be visible outside its viewport bounds.
  AiVectra owns the viewport bounds, scroll offset, and event semantics. Hosts
  may accelerate clipping mechanically, but hosts must not own scroll state,
  layout decisions, or event meaning.
