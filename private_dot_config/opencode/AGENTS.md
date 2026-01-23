# OpenCode Config

Chezmoi-managed opencode configuration. Deploys to `~/.config/opencode/`.

## Structure

```
~/.config/opencode/
├── opencode.json          # Main config: permissions, plugins, providers, MCP servers, LSPs
├── oh-my-opencode.json    # Agent models, category mappings
├── command/               # Custom slash commands
├── plugin/                # Custom JS plugins
└── themes/                # Custom themes
```

## Editing

Edit files directly in `~/.config/opencode/`, then sync to chezmoi:

```bash
chezmoi re-add ~/.config/opencode
cd ~/.local/share/chezmoi && git add -A && git commit -m "chore: sync opencode config" && git push
```

## Custom Commands

| Command | Purpose |
|---------|---------|
| `/create-pr` | Create PR with standard format |
| `/quick-fix` | Quick fix workflow |
| `/session-resume` | Resume previous session |
| `/work-on-linear-issue` | Deep-dive Linear issues |
| `/resolve-pr-comments` | Address PR feedback |
| `/reorganize-commits` | Interactive rebase with Conventional Commits |
| `/conventional-commits` | Draft/validate commit messages |
| `/clean` | Clean up tech debt |
| `/deslop` | Remove AI-generated slop |

## Custom Plugins

| Plugin | Purpose |
|--------|---------|
| `compaction-preserver.js` | Preserve context during compaction |
| `auto-test.js` | Auto-run tests |

## Installed Plugins

- `oh-my-opencode` - Agent orchestration & delegation
- `opencode-antigravity-auth` - Google Antigravity auth
- `opencode-openai-codex-auth` - OpenAI OAuth
- `opencode-anthropic-auth` - Anthropic auth

## Agent Categories

Configured in `oh-my-opencode.json`:

| Category | Model | Use Case |
|----------|-------|----------|
| `visual-engineering` | Gemini 3 Pro | Frontend, UI/UX, styling |
| `ultrabrain` | GPT 5.2 Codex | Deep reasoning, complex architecture |
| `artistry` | Gemini 3 Pro Max | Creative tasks |
| `quick` | Claude Haiku 4.5 | Trivial tasks, single file changes |
| `unspecified-low` | Claude Sonnet 4.5 | General low-effort |
| `unspecified-high` | Claude Opus 4.5 | General high-effort |
| `writing` | Gemini 3 Flash | Documentation, prose |

## Specialized Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| `Sisyphus` | Claude Opus 4.5 | Main orchestrator |
| `oracle` | GPT 5.2 Codex | Read-only consultant, debugging |
| `explore` | Claude Haiku 4.5 | Codebase contextual grep |
| `librarian` | GLM 4.7 | External docs, OSS examples |
| `multimodal-looker` | Gemini 3 Pro | PDF/image analysis |

## MCP Servers

- Linear - Issue tracking
- Notion - Documentation

## LSP Servers

Configured for: Rust, Go, YAML, TypeScript/JavaScript

## Notes

- Gitignored (generated locally): `node_modules/`, `bun.lock`, `package.json`
- Gitignored (secrets): `antigravity-accounts.json`, `antigravity-signature-cache.json`, `antigravity-logs/`
