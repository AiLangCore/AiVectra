# AiVectra Release Checklist

Use this checklist for alpha, beta, release-candidate, and stable AiVectra releases.

## Preflight

- Confirm the release branch follows the workspace Git Flow policy.
- Confirm README, specs, samples, and `CHANGELOG.md` describe the current SDK surface.
- Confirm sample projects do not contain generated `.toolchain/` or `app.aibc1` output.
- Confirm AiVectra still treats AiLang as the semantic authority and does not define language behavior.

## Local Verification

```bash
bash -n ./scripts/aivectra
find ./scripts -type f -name '*.sh' -print | sort | xargs -I{} bash -n {}
./scripts/check-node-ids.sh
```

When a compatible AiLang toolchain is available, run the broader suite:

```bash
./scripts/doctor.sh
./scripts/test-all.sh
```

Set `AIVECTRA_SCREENSHOT_TEST=1` only when the local host has the required GUI permissions.
Set `AIVECTRA_SCREENSHOT_TOOL=/path/to/take_screenshot.py` when the screenshot
helper is not installed under `$CODEX_HOME/skills/screenshot`.
The current alpha still contains sample-level direct syscall usage; treat
`test-all` failures from `test-no-direct-syscalls-in-samples.sh` as a known
pre-1.0 hardening item until those samples are migrated behind the public
AiVectra API.

## Release

- Push the release branch and confirm GitHub Actions pass.
- Tag with `v<version>`, for example `v0.0.1-alpha.13`.
- Confirm the GitHub release is marked as a prerelease for `-alpha`, `-beta`,
  `-rc`, and `-local` tags.
- Confirm `.tar.gz` and `.zip` artifacts are attached.

## Post-Release

- Update `CHANGELOG.md` for the released version if needed.
- Update the website release page with the known-good AiLangCore alpha set.
- Merge the release branch back according to Git Flow.
