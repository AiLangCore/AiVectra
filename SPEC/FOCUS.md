# Focus

## Model
- Single focused node id at any time.
- Focus is engine mechanical state.
- Focus key is explicit interactive node `id`.

## Rules
- Pointer down on focusable node sets focus to that node id.
- Pointer down outside focusable nodes clears focus.
- No tab navigation in MVP.
- No bubbling/capture phases.

## Determinism
- Focus transitions are pure function of previous state + canonical event payload.
