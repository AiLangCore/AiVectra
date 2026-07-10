# Changelog

All notable changes to AiVectra are documented in this file.

## [0.0.1-beta.3] - 2026-07-10

### Changed

- Stabilized the package-owned runtime path and incremental scene rendering
  behavior used by the production-style WeatherApp sample.
- Kept platform targets outside the UI SDK so their hosts, packaging, and CI
  can evolve independently of AiVectra semantics.

### Notes

- This remains an early-beta UI SDK release. The documented MVP support matrix
  is the authoritative statement of supported UI behavior.

## [0.0.1-beta.2] - 2026-05-27

### Changed

- Updated samples and package source files to use SDK-owned AiLang imports.
- Moved AiVectra text helpers to the staged deterministic `std.str` surface.
- Added the AiVectra package source descriptor for the beta package registry
  flow.
- Polished public README status for the beta branch/release story.

### Notes

- This is a beta UI SDK release. Pre-1.0 runtime behavior and project layout may
  still change.

## [0.0.1-beta.1] - 2026-05-19

### Changed

- Promoted the AiVectra SDK packaging line to the first beta release.
- Updated local tooling to use `tools/ailang` instead of the old `tools/airun`
  wrapper name.
- Kept the AiVectra CLI/package release artifacts focused on sources, specs,
  samples, and the `aivectra` wrapper.

### Notes

- This is a beta UI SDK release. Pre-1.0 runtime behavior and project layout may
  still change.

## [0.0.1-alpha.10] - 2026-04-28

### Added

- Alpha SDK package with AiVectra sources, CLI wrapper, specs, and samples.
- Release artifacts in `.tar.gz` and `.zip` formats.
- Sample projects for deterministic vector UI experiments.
- Debug and golden-test scripts for local validation.

### Notes

- This is an alpha UI SDK release. Runtime behavior and project layout may change before `1.0`.
- AiLang and AiVM are released from their own repositories.
