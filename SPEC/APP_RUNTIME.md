# App Runtime

## Purpose
AiVectra provides one standard app runtime module that owns:
- main UI/semantic loop
- event polling/translation
- deterministic state transition
- worker result integration
- shutdown/cancel flow

Apps provide declarative behavior hooks. Apps do not own low-level loop mechanics.

## Runtime Ownership
- AiVectra runtime owns frame/event orchestration.
- App code owns state shape and pure state transitions.
- Worker execution is mechanical; semantic state mutation remains on UI/semantic thread.

## Required App Hooks
- `appInit(args) -> state`
- `appRender(windowHandle, state) -> void`
- `appUpdate(state, eventType, eventKey, eventText, eventX, eventY, windowWidth, windowHeight) -> state`

Optional:
- `appHandleWorker(state, workerMessage) -> state`
- `appOnShutdown(state) -> void`

## Event Contract
Current runtime passes flattened canonical event fields plus current window metrics:
- `eventType`
- `eventKey`
- `eventText`
- `eventX`
- `eventY`
- `windowWidth`
- `windowHeight`

Current event conventions:
- `eventType="none"` indicates a frame tick with no host event.
- `eventType="closed"` indicates window close.

Planned direction after current convergence:
- move from flattened event args to a single canonical event value once the runtime contract is ready to freeze.

## Determinism Rules
- All state mutation occurs on the single semantic thread.
- Worker messages are serialized by deterministic queue order.
- No implicit mutation, hidden timers, or side-channel state.

## Syscall Boundary Rule
- App/sample code must not call `sys.*` directly after runtime bootstrap.
- Runtime module is the only path for UI/event/worker effects.

## Template Rule
- Canonical template (`aivectra init`) must use this runtime model.
- Samples are runtime consumers and must follow the same public app runtime API.
