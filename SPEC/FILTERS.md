# Filters

## Scope
Minimal deterministic filter support only.

## MVP Filter
- `gaussianBlur(radius)` implemented as deterministic multi-band draw expansion in AiLang.

## Rules
- Radius must be deterministic and finite.
- Filter output must be deterministic for same input scene.
- MVP implementation is a software approximation and does not require host GPU/filter syscalls.
- No filter graph composition in MVP.
- No async/GPU dependency semantics in spec.

## Non-Goals
- Arbitrary filter chains
- Color matrix/composite graphs
- Time-varying filters
