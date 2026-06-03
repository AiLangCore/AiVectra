AiVectra Sample App Rules

- This app is a consumer of AiVectra public API.
- Do not call `sys.*` directly from sample source.
- Keep app deterministic and non-blocking.
- GUI lifecycle must use `guiBuild` and `guiRun` from AiVectra.
- Implement app behavior through `appRender` and `appUpdate` hooks only.
