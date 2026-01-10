# OpenCode Config

Chezmoi-managed opencode configuration. Deploys to `~/.config/opencode/`.

## Files

| File | Purpose |
|------|---------|
| `opencode.json` | Main config: permissions, plugins, providers, MCP servers |
| `oh-my-opencode.json` | Agent models, category mappings |

## Editing

Edit source files here, then `chezmoi apply`. Never edit target (`~/.config/opencode/`) directly.

## Plugins

- `oh-my-opencode` - Agent orchestration
- `opencode-antigravity-auth` - Google Antigravity auth
- `opencode-openai-codex-auth` - OpenAI OAuth

## MCP Servers

- Linear
- Notion

## Adding Models

Add to `opencode.json` under `provider.{provider}.models`. Match existing structure.

## Notes

- `node_modules/`, `bun.lock`, `package.json` are gitignored (generated locally by plugins)
- Auth tokens stored separately (not in config)
