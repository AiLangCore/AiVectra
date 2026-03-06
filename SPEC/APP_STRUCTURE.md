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

  Src/
    app.aos

  Assets/
    Bundle/
    Icons/
    Splash/
    Fonts/
    Images/
    Locale/

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
- Use `Src` (not `src`) for app source root.
- Use lowercase `www` for web roots.
- `Assets/Bundle` contains generic files copied directly into target bundles.
- Derived assets are generated into build staging/`dist`, not committed under source assets.

## Target Metadata
- Platform metadata sources are TOML templates under `Targets/**`.
- Build generates concrete platform files (plist/manifest/desktop entry/etc.) into build output.

## Template Rule
- `aivectra init` must emit this exact structure.
- Samples intended as canonical templates must match this structure exactly.
