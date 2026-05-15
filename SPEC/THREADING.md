# AiVectra Threading Model

## Purpose

AiVectra requires a deterministic threading model for UI applications.

This document defines the threading requirements for AiVectra apps, samples, runtime code, and host integration.

## Normative Model

AiVectra uses:

- one UI/Semantic thread
- zero or more worker threads
- one deterministic AiVM event queue

The UI/Semantic thread is the only thread allowed to mutate semantic application state or the live UI scene graph.

Worker threads are mechanical execution resources only.

## UI/Semantic Thread

The UI/Semantic thread owns:

- application state mutation
- UI tree mutation
- event handling
- layout-triggering state changes
- render scheduling decisions
- worker result integration

The UI/Semantic thread must not:

- sleep
- block on I/O
- wait synchronously for worker completion
- perform long-running computation
- mutate state outside canonical event dispatch

Blocking the UI/Semantic thread is incorrect.

## Worker Threads

Worker threads may perform:

- blocking I/O
- long-running computation
- background parsing
- background validation
- data loading
- platform work that must not run on the UI/Semantic thread

Worker threads must not:

- mutate application state directly
- mutate the live UI scene graph
- access UI objects directly
- create independent event queues
- introduce hidden timers
- rely on nondeterministic result ordering

Workers communicate completion only by posting messages to the AiVM deterministic event queue.

## Cross-Thread Communication

All cross-thread communication must pass through the AiVM deterministic event queue.

Worker results must be represented as messages.

The event queue serializes worker messages before they are applied to semantic state.

Observable state changes occur only when the UI/Semantic thread processes those messages.

## Shared State

Shared mutable semantic state across threads is forbidden.

Allowed shared data:

- immutable compiled modules
- immutable assets
- immutable frozen messages
- host-owned opaque handles that do not define AiVectra semantics

Forbidden shared data:

- mutable UI nodes
- mutable application state
- mutable AiLang values visible to multiple workers
- host-side mutable state that affects semantic behavior outside the event queue

## Event Loop Authority

AiVectra must not create a second semantic event loop.

There is exactly one semantic event authority: AiVM.

The host may provide platform window events and rendering callbacks, but semantic event ordering and state transitions must remain under AiVM event queue control.

## Determinism Requirements

Thread scheduling must not affect observable AiVectra behavior.

The following must be deterministic:

- event order after queue serialization
- worker result integration
- state transition order
- render-triggering state changes
- shutdown/cancel processing

Host thread scheduling is mechanical only and must not define language or UI semantics.

## Layer Ownership

AiVM owns:

- worker thread pool mechanics
- deterministic event queue mechanics
- thread scheduling mechanics
- syscall dispatch boundary

AiLang owns:

- concurrency primitives
- spawn semantics
- message passing semantics
- handler semantics
- deterministic state transition semantics

AiVectra owns:

- UI event translation
- vector scene graph mutation rules
- render scheduling policy
- UI/runtime integration with the AiLang/AiVM event system

AiVectra does not own:

- general concurrency primitives
- general worker scheduling
- file I/O
- network I/O
- timers
- synchronization primitives

If a needed threading capability is missing, define it in AiLang or AiVM before using it from AiVectra.

## App Runtime Requirement

The standard AiVectra app runtime must follow this threading model.

Apps and samples must be runtime consumers.

App/sample code must not bypass the runtime by calling host threading APIs or direct `sys.*` effects after runtime bootstrap.

## Prime Rule

Parallel work is allowed.

Nondeterministic semantic mutation is not.
