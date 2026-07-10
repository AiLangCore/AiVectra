# AiVectra Rendering Model

Status: normative AiVectra rendering contract.

## Scope

This specification defines AiVectra-owned vector scene and rendering behavior.
It does not define AiLang application semantics or AiVM execution mechanics.

## Vector-First Model

AiVectra UI output must be represented using resolution-independent vector
primitives and explicit layout constructs.

- Rendering must not rely on raster-first assumptions.
- Layout must not depend on one fixed output resolution.
- Raster assets may be embedded as explicit image resources, but they must not
  become the semantic representation of the scene.

## Scene Model

AiVectra uses a retained vector scene representation.

For a fixed program state, canonical input event stream, viewport, target, and
font/rendering profile, scene construction must be deterministic.

Scene structure must preserve:

- explicit node and target identity where interaction requires identity
- deterministic child ordering
- deterministic layout inputs
- deterministic paint ordering
- explicit clipping and viewport boundaries

## Layout

Layout evaluation must be predictable, canonical, and testable through golden
outputs.

- Platform renderers must not substitute platform-native layout decisions for
  AiVectra layout results.
- Hidden host measurement passes must not define observable layout behavior.
- Equivalent supported hosts must receive equivalent canonical layout data for
  the same specified inputs and rendering profile.
- Viewport and scroll state are AiVectra-owned semantic UI state, not host-owned
  layout state.

## Paint Order

Paint order must follow canonical scene order.

- There is no implicit host-defined z-index behavior.
- Overlap behavior must derive from explicit scene structure and ordering.
- Hosts may batch or accelerate drawing mechanically only when the resulting
  image remains equivalent to canonical paint order.

## Host Boundary

Platform renderers are mechanical adapters. They may:

- translate vector instructions to native drawing surfaces
- provide normalized input events
- provide surface lifecycle management
- accelerate clipping, compositing, and drawing mechanically

They must not:

- define application or UI state transitions
- reorder semantic events
- introduce platform-dependent layout rules
- retain hidden UI state that changes scene meaning
- infer business behavior from native controls or window-manager behavior

## Determinism And Conformance

Rendering conformance is established through the visual contract in
`VISUAL_CONTRACT.md`.

If rendering behavior changes:

1. Update the applicable specification.
2. Update canonical golden artifacts.
3. Update implementation.

Implementation changes must not establish new behavior before the specification
and conformance artifacts describe it.
