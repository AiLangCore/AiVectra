# App Structure

## Canonical Project File
- Every AiVectra app uses `project.aiproj` as the canonical project file.
- `project.aiproj` is the source of truth for:
  - app identity
  - display name
  - version
  - target matrix
  - app entry file/export
- No alternate extension is required.

## Canonical Layout
```text
MyApp/
  project.aiproj
  AGENTS.md
  README.md

  src/
    app.aos

    Assets/
      bundle/
      icons/
      splash/
        background.svg
        foreground.svg
      fonts/
      images/
      locale/

    Targets/
      Apple/
        Mac/
      Microsoft/
        Windows/
      Linux/
      Web/
        www/
        WasmSpa/
          www/
        WasmFullStack/
          www/

  .toolchain/   (generated, gitignored)
```

## Naming Rules
- Use `src` for app source root.
- Use lowercase names for concrete asset buckets: `bundle`, `icons`, `fonts`, `images`, `locale`.
- Use `src/Assets/Splash/background.svg` and
  `src/Assets/Splash/foreground.svg` as the canonical cross-target app splash
  assets. Target packages may transform these assets for their platform
  boot/loading surfaces, including AiOS boot splash, mobile launch screens, and
  web loading shells.
- Use lowercase `www` for web roots.
- `src/Assets/bundle` contains generic files copied directly into target bundles.
- Derived assets are generated into build staging/`dist`, not committed under source assets.

## Target Metadata
- Platform metadata sources are TOML templates under `src/Targets/**`.
- Build generates concrete platform files (plist/manifest/desktop entry/etc.) into build output.

## Template Rule
- `aivectra init` must emit this exact structure.
- Samples intended as canonical templates must match this structure exactly.
