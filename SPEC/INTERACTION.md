# Interaction

## Hit Testing
- Hit testing order is reverse render order (topmost first).
- First matching node wins.
- Single target only.
- No bubbling in MVP.

## Geometry
- `Rect`: axis-aligned bounding test.
- `Ellipse`: deterministic MVP approximation (bounds + center bands), no floating-point math.
- `Path`: deterministic MVP bounding-box test (`pointInPathBounds`).

## Path Fill Rule
- Target fill rule is `EVEN-ODD` once path point-in-path parsing is added.
- Current MVP does not parse path internals for hit testing; it uses explicit bounds.

## Pointer Events
- `PointerDown`
- `PointerUp`
- `PointerMove` (optional in MVP)

## Click Synthesis
`onClick` fires only when:
- pointer down occurs inside node
- pointer up occurs inside same node
- pointer does not leave node bounds between down/up

Every input event causes full deterministic recompute.
