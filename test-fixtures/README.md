# AiVectra Test Fixtures

These fixtures are repo-local proof points for AiVectra regression tests. Public
examples live in the sibling `ailang-examples` repository under
`examples/aivectra/`.

Fixtures should stay small, deterministic, and runnable from the repository root with
`./scripts/aivectra run`.

## Supported Fixtures

| Sample | Purpose | Command | Status |
| --- | --- | --- | --- |
| `HelloWorld` | Minimal app structure and rendering baseline. | `./scripts/aivectra run ./test-fixtures/HelloWorld/` | Supported |
| `HelloName` | Text input, keyboard events, click handling, and deterministic replay. | `./scripts/aivectra run ./test-fixtures/HelloName/` | Supported |
| `InteractiveSvgMvp` | Deterministic SVG/debug artifact behavior for interactive vector UI. | `./scripts/aivectra run ./test-fixtures/InteractiveSvgMvp/ snapshot` | Supported |
| `WorkerDemo` | Background worker direction and UI update flow. | `./scripts/aivectra run ./test-fixtures/WorkerDemo/` | Experimental |

## Deferred Samples

| Sample | Reason |
| --- | --- |
| `WeatherApp` | Network-backed app. Keep deferred until HTTP/package/runtime boundaries are stable enough for public demos. |
| `HttpProbe` | Internal host-network probe. Not a public app sample. |

## Sample Contract

- Source apps use lowercase `src/app.aos`.
- Each project fixture has `project.aiproj` with an `entryFile` that points to an
  existing file.
- Fixtures must not contain OS metadata such as `.DS_Store`.
- Fixtures should not call `sys.*` directly unless the fixture is explicitly about
  the syscall boundary.
- Supported fixtures must pass deterministic run-mode checks in
  `./scripts/test-all.sh`.
