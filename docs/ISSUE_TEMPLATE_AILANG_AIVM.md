# Capability Gap: <short title>

## Requesting Project
- Repo: AiVectra
- Date: <YYYY-MM-DD>
- Requested by: <agent/user>

## Summary
AiVectra cannot implement `<feature>` within architecture boundaries because a required capability is missing in `<AiLang|AiVM>`.

## Blocking Use Case
- App/Sample: `<name>`
- User-visible behavior needed: `<what must happen>`
- Why this is required now: `<delivery/priority reason>`

## Missing Capability
- Layer owner: `<AiLang|AiVM>`
- Capability: `<exact missing primitive/contract>`
- Current behavior: `<what happens today>`
- Expected behavior: `<what AiVectra needs>`

## Why AiVectra Cannot Own This
- Boundary rule: `<cite rule>`
- If implemented in AiVectra, this would cause: `<determinism break / semantic leak / host coupling>`

## Minimal Contract Proposal
### Option A (preferred)
- API/Spec shape:
  - `<signature>`
  - `<input/output>`
  - `<error semantics>`
- Determinism constraints:
  - `<ordered events / stable payload / no hidden state>`
- Notes:
  - `<migration impact>`

### Option B
- API/Spec shape:
  - `<signature>`
- Tradeoffs:
  - `<cons>`

## Acceptance Criteria
1. `<testable condition>`
2. `<testable condition>`
3. `<testable condition>`

## Compatibility / Migration
- Required AiVectra changes after merge:
  1. `<item>`
  2. `<item>`
- Backward compatibility needed: `<yes/no>`

## References
- AiVectra file(s): `<absolute path>`
- Relevant spec sections: `<doc + section>`
- Repro command(s):
  - `<command>`
  - `<command>`
- Observed output:
  - `<error code/message>`
