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
- `appUpdate(state, event) -> state`

Optional:
- `appHandleWorker(state, workerMessage) -> state`
- `appOnShutdown(state) -> void`

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

## Syscall Boundary Rule
- App/sample code must not call `sys.*` directly after runtime bootstrap.
- Runtime module is the only path for UI/event/worker effects.

## Template Rule
- Canonical template (`aivectra init`) must use this runtime model.
- Samples are runtime consumers and must follow the same public app runtime API.
