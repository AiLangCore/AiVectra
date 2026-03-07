# Scene

## Node Kinds
- `Group`
- `Rect`
- `Ellipse`
- `Path`
- `Text`
- `Transform`
- `Defs`
- `Symbol`
- `Use`

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

## Reuse Model

### Purpose
- AiVectra must support reusable scene fragments in a way conceptually similar to SVG `defs`, `symbol`, and `use`.
- Reuse exists to reduce duplication in vector scenes, keep authored structure stable, and make AI-driven modification safer.
- Reuse is a scene capability, not a widget system.

### Reuse Nodes
- `Defs`
  - Declares reusable scene definitions for the current scene.
  - `Defs` does not render directly.
- `Symbol`
  - Defines a named reusable scene fragment.
  - A `Symbol` must have a stable `id`.
  - A `Symbol` may contain any normal scene children that are valid at its definition point.
- `Use`
  - Instantiates a previously declared `Symbol`.
  - A `Use` must name the `symbolId` it references.
  - A `Use` must have its own stable instance identity.

### Determinism Rules
- Symbol lookup is by explicit id only.
- A `Use` must fail explicitly if the referenced `symbolId` does not exist.
- Expansion order is deterministic and equivalent to inline scene expansion at the `Use` node position.
- A `Use` instance must not mutate the referenced `Symbol`.
- Reuse must never depend on host behavior or hidden caches.

### Identity Rules
- `Symbol` identity and `Use` identity are distinct.
- `Symbol` id names the reusable definition.
- `Use` instance id names the concrete occurrence in the scene.
- Debug/inspection output must preserve both:
  - definition identity
  - instance identity

### Interaction Rules
- AiVectra does not attach implicit behavior to `Symbol` or `Use`.
- Interaction remains explicit and state-driven.
- Reused content must still use explicit event target ids and explicit state-driven appearance.
- If reused content needs distinct interaction targets per instance, those targets must be parameterized or explicitly namespaced by the instance.

### Parameterization Direction
- MVP reuse may begin with:
  - definition id
  - instance id
  - translation/placement
- The intended next step is explicit parameter binding for:
  - text values
  - fills/strokes
  - target ids
  - other scene attributes
- Parameter binding must remain explicit and deterministic.

### Transform And Placement
- `Use` must support deterministic placement of the referenced symbol.
- MVP placement should be translation only, matching current `Transform` constraints.
- Future transform support may expand, but reuse semantics must remain stable.

### Debugging And Inspection
- Scene inspection output must make reuse visible.
- A debug view must be able to answer:
  - which symbol definition a node came from
  - which concrete instance produced it
  - where expansion occurred in render order

### Forbidden Behavior
- No widget semantics attached to `Symbol` or `Use`.
- No hidden local mutable instance state.
- No host-side interpretation of symbol reuse.
- No silent fallback when a symbol reference is invalid.

### Sample Usage Direction
- Samples should use reuse to demonstrate AiVectra scene capability.
- Reusable button-like visuals in samples must be expressed as reusable vector scene fragments, not engine-level controls.
