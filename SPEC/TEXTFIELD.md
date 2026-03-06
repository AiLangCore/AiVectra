# TextField

## Contract
- `id` (required)
- `value` (source of truth)
- `onChange(newValue)`

## MVP Editing
- Single-line only
- Character insertion
- Backspace
- Left/Right caret movement
- No selection
- No clipboard
- No IME
- No multiline

## Routing
- Keyboard and text input are routed only to focused node.
- If no focus, keyboard/text input are ignored.

## Internal Mechanical State
- Caret position keyed by `(TextField,id)`.
- Internal mechanical buffer may exist only to process edits deterministically.
- Application state remains source of truth via `value`.
