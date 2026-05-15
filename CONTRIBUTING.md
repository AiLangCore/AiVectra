# Contributing to AiVectra

AiVectra owns the vector UI library, UI SDK, rendering contracts, input mapping,
and UI samples for AiLang. AiLang owns language semantics. AiVM owns runtime
execution, scheduling mechanics, and the syscall boundary.

## Branches

AiVectra uses Git Flow. The default integration branch is `develop`.

- Branch feature work from `develop`.
- Keep UI changes spec-governed and testable.
- Do not add compatibility layers before the first major or minor release unless
  explicitly requested. Replace old contracts consistently when direction
  changes.

## Local Setup

For core development, clone the main repositories as siblings:

```bash
mkdir AiLangCore
cd AiLangCore
git clone https://github.com/AiLangCore/AiLang.git
git clone https://github.com/AiLangCore/AiVM.git
git clone https://github.com/AiLangCore/AiVectra.git
git clone https://github.com/AiLangCore/ailang-packages.git

git -C AiLang checkout develop
git -C AiVM checkout develop
git -C AiVectra checkout develop
```

Use the installed AiLang SDK for normal sample and package checks.

## Verification

Run from the AiVectra repository root:

```bash
./scripts/test-all.sh
```

Host screenshot parity is optional because it requires GUI permissions and a
screenshot helper:

```bash
AIVECTRA_SCREENSHOT_TEST=1 \
AIVECTRA_SCREENSHOT_TOOL=/path/to/take_screenshot.py \
./scripts/test-all.sh
```

## Contribution Rules

- AiVectra must not define language behavior.
- Observable semantic mutation must occur through deterministic AiVM queue
  dispatch.
- Workers may perform mechanical/background work, but must not mutate UI state
  directly.
- UI samples must remain real UI samples. No-window modes must emit meaningful
  deterministic scene/debug artifacts.
- Keep generated outputs out of commits: `.toolchain/`, `.tmp/`, `.artifacts/`,
  `app.aibc1`, local SDK files, and local notes.
- If layout or interaction behavior changes, update `SPEC/`, samples, and tests
  in the same change.
