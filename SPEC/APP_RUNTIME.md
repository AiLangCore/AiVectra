# App Runtime

## Purpose

AiVectra currently provides a GUI runtime adapter that owns the mechanical UI
integration needed by AiVectra apps:

- current GUI loop adapter
- event polling/translation
- deterministic state transition
- worker result integration
- shutdown/cancel flow

Apps provide declarative behavior hooks. Apps do not own low-level loop
mechanics. Generic application lifecycle semantics belong to `std-app`.
The long-term target is `State + Event -> Next`, owned by `std-app`. AiVectra is
one runtime profile adapter: it converts GUI host events into `std-app` events
and consumes `std-app` commands that request GUI effects.

## Related Specs

- `SPEC/THREADING.md`

## Runtime Ownership

- `std-app` owns generic lifecycle vocabulary: context, event, message, command,
  worker, and `State + Event -> Next` contracts.
- AiVectra owns GUI frame/event plumbing while the GUI adapter lives here. It
  must not become the permanent owner of application lifecycle semantics.
- App code owns state shape and pure state transitions.
- Worker semantics are defined by `std-app`. AiVM and host code own only
  mechanical scheduling and execution.

## Required App Hooks

- `appInit(args) -> state`
- `appUpdate(state, event) -> Next`
- `appRender(windowHandle, state) -> void`

Optional:

- `appHandleWorker(state, workerMessage) -> Next`
- `appOnShutdown(state)`

## Event Contract

Runtime passes canonical UI events only:

- `type`
- `targetId`
- `x`
- `y`
- `key`
- `text`
- `modifiers`
- `repeat`

## Determinism Rules

- All state mutation occurs on the single semantic thread.
- Worker messages are serialized by deterministic queue order.
- No implicit mutation, hidden timers, or side-channel state.
- Thread scheduling must not affect observable behavior.

## Syscall Boundary Rule

- App/sample code must not call `sys.*` directly after runtime bootstrap.
- The current GUI adapter is the only path for GUI host effects. Generic loop
  semantics, worker semantics, and non-GUI lifecycle contracts route through
  `std-app`.

## Template Rule

- Canonical template (`aivectra init`) must be compatible with the `std-app`
  `State + Event -> Next` lifecycle model.
- Samples are runtime consumers and must follow the same public app runtime API.
