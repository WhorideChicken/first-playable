# Security Policy

## Scope

FirstPlayable is a Claude Code plugin consisting of Markdown instructions and
document templates. It bundles no executable binaries and no MCP server
implementation. Still, plugin instructions influence what an AI agent does in
your project, so we treat instruction-level risks seriously:

- Instructions that could cause destructive file operations
- Instructions that could leak secrets or personal paths into generated docs
- Prompt-injection vectors via templates or generated documents

## Reporting

Please report vulnerabilities via
[GitHub private vulnerability reporting](https://github.com/WhorideChicken/first-playable/security/advisories/new)
rather than public issues. You can expect an initial response within 7 days.

## Supported versions

Only the latest release receives security fixes.
