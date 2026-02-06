# dotfiles

Personal macOS environment managed with [chezmoi](https://chezmoi.io) and [1Password](https://1password.com).

## Quick Start (New Machine)

```bash
# 1. Install Homebrew + chezmoi
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install chezmoi 1password-cli

# 2. Bootstrap 1Password service account token
export OP_SERVICE_ACCOUNT_TOKEN="<sawmills-sa-token-from-1password>"

# 3. Initialize dotfiles (will prompt for machine type, email, name)
chezmoi init --apply amir-jakoby
```

This will:
- Prompt for machine type (`personal`/`work`), email, and name
- Pull secrets from 1Password
- Install Homebrew packages from `~/.Brewfile`
- Set up shell, git, and terminal configs

## What's Included

| Component | Description |
|-----------|-------------|
| **Shell** | Zsh + Prezto + Starship prompt |
| **Terminal** | Ghostty config |
| **Git** | Config with GPG signing |
| **Packages** | Brewfile with core tools |
| **Secrets** | 1Password integration |

## Daily Usage

| Command | Description |
|---------|-------------|
| `chezmoi apply` | Apply latest dotfiles |
| `chezmoi update` | Pull & apply from repo |
| `chezmoi edit ~/.zshrc` | Edit managed file |
| `chezmoi add ~/.newfile` | Track a new file |
| `chezmoi diff` | Preview pending changes |
| `chezmoi cd` | Open source directory |

## Structure

```
.
├── .chezmoi.toml.tmpl              # Config template (prompts on init)
├── .chezmoiexternal.toml           # External repos (Prezto)
├── .chezmoiignore                  # Files to skip
├── dot_Brewfile                    # Homebrew packages
├── dot_gitconfig.tmpl              # Git config (secrets from 1Password)
├── dot_zshenv.tmpl                 # Environment variables + secrets
├── dot_zshrc                       # Zsh config
├── dot_zpreztorc                   # Prezto modules
├── dot_zsh/                        # Custom zsh scripts
├── private_dot_config/
│   ├── starship.toml               # Starship prompt
│   └── ghostty/config              # Ghostty terminal
├── run_once_before_*.sh.tmpl       # One-time setup scripts
└── run_onchange_*.sh.tmpl          # Scripts triggered by file changes
```

## Secrets

All secrets live in 1Password **Dotfiles** vault (ID: `twc5qlrgqquiaworifv5eczvhy`), accessed via a Sawmills service account.

chezmoi runs in `service` mode — no interactive `op signin` needed. Just set `OP_SERVICE_ACCOUNT_TOKEN` before running.

| Item | Fields |
|------|--------|
| GPG | `key-id` |
| GitHub | `email` |
| GoReleaser | `key` |
| Clerk | `staging`, `preprod`, `prod` |
| Sawmills OP Service Account Token | `credential` |
| LaunchDarkly Access Token | `credential` |

### Adding a New Secret

```bash
# 1. Create in 1Password (use vault ID to avoid ambiguity)
op item create --vault twc5qlrgqquiaworifv5eczvhy --category "API Credential" \
  --title "ServiceName" "token=your-secret-value"

# 2. Reference in template (use vault ID, not name)
chezmoi edit ~/.zshenv
# Add: export SERVICE_TOKEN={{ onepasswordRead "op://twc5qlrgqquiaworifv5eczvhy/ServiceName/token" | quote }}

# 3. Apply
chezmoi apply
```

## Machine-Specific Config

Set during `chezmoi init` or in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
  machine = "personal"  # or "work"
```

Use in templates:
```
{{ if eq .machine "work" }}
export CORP_PROXY=http://proxy.corp:8080
{{ end }}
```

## Prerequisites

- macOS
- [1Password CLI](https://developer.1password.com/docs/cli) (`op`)
- Sawmills 1Password service account token (for `OP_SERVICE_ACCOUNT_TOKEN`)
- Access to `Dotfiles` vault (ID: `twc5qlrgqquiaworifv5eczvhy`)

## Documentation

See [HANDBOOK.md](HANDBOOK.md) for detailed setup, configuration, and troubleshooting.

## License

MIT
