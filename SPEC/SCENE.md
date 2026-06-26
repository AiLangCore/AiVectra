# Scene

## Node Kinds
- `Group`
- `Rect`
- `Ellipse`
- `Path`
- `Text`
- `Transform`

## Core Rules
- Scene is declarative and immutable per frame.
- Render order is tree order.
- Last rendered node is visually topmost.
- Nodes may contain children.
- Nodes may define fill and stroke.

## Incremental Rendering
- Renderers should retain the previous scene and redraw only regions affected
  by changed, added, removed, resized, or reordered nodes.
- Full-surface redraw is allowed only for first paint, resize, explicit
  full-surface invalidation, renderer recovery, or a target that has no partial
  update mechanism.
- Dirty region calculation is deterministic AiVectra behavior. Hosts may
  accelerate copying or presentation mechanically, but hosts must not decide UI
  semantics, layout, event meaning, or application state.
- Scroll, cursor, hover, text editing, animation, and popup updates should
  invalidate the smallest deterministic region that can produce correct pixels.
- Back buffering may be used to avoid tearing, but it is not a replacement for
  scene diffing and dirty-region presentation.

## Transform MVP
- `Transform` supports translation only for MVP.
- Translation applies deterministically to children.

## Paint MVP
- Solid fill and stroke supported.
- Gradients supported via deterministic engine primitives.
- Gaussian blur filter supported as minimal filter MVP.
