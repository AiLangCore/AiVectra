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

## Transform MVP
- `Transform` supports translation only for MVP.
- Translation applies deterministically to children.

## Paint MVP
- Solid fill and stroke supported.
- Gradients supported via deterministic engine primitives.
- Gaussian blur filter supported as minimal filter MVP.
