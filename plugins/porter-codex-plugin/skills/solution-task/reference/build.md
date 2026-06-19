# build — Solution Task Reference

## Read From SOLUTION.md

- `Goal`
- `Scope`
- `Type-Specific Analysis`
- `Acceptance`
- `Risks`

## Task Types

- Build config changes.
- Script or package metadata changes.
- Build command verification.
- Artifact verification.

## Ordering

- Modify configuration before validation.
- Always include the build command or structural verification command when available.
- Always verify the expected artifact when the build produces one.
- If the build has no persistent artifact, record why and verify the observable output instead.

## Template

```markdown
## Task N: <build change>

无业务逻辑，无需测试；通过构建验证和产物验证。

- [ ] Update `<config_path>`
- [ ] 运行构建：<build command or structural check>
- [ ] 验收标准：<expected build behavior or artifact state from SOLUTION.md Acceptance>
- [ ] 验证方式：<build command, structural check, or downstream load check>
- [ ] 产物验证：<artifact path, file list, metadata, size, manifest, package, or generated output>
- [ ] 记录无产物原因：<only when the build does not produce a persistent artifact>
```

## Artifact Verification

产物验证至少覆盖一项：

- Expected artifact path exists.
- Expected generated file list matches the build goal.
- Package, bundle, manifest, checksum, version, or metadata is correct.
- Generated output can be inspected or loaded by the expected downstream tool.
- No stale artifact from a previous build is being mistaken for the new output.
