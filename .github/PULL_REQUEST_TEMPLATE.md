## Summary

- 

## Scope

- [ ] Vector rendering or scene contract change
- [ ] Input, focus, or window lifecycle change
- [ ] Sample, template, package, or CLI change
- [ ] Specification or documentation change

## Verification

- [ ] `./scripts/test-all.sh`
- [ ] Screenshot parity checked when host rendering changed
- [ ] Specs, samples, and golden outputs updated when behavior changed

## Architecture Checklist

- [ ] AiVectra does not define language behavior
- [ ] Observable semantic mutation occurs through deterministic queue dispatch
- [ ] Workers do not mutate UI state directly
- [ ] No-window modes emit meaningful deterministic scene/debug artifacts
- [ ] Generated files are not included (`.toolchain/`, `.tmp/`, `.artifacts/`,
      `app.aibc1`, local SDK files, local notes)
- [ ] No backward compatibility layer was added before the first major/minor
      release unless explicitly requested
