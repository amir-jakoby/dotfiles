# dotfiles

Personal macOS environment managed with [chezmoi](https://chezmoi.io) and [1Password](https://1password.com).

## Quick Start (New Machine)

```bash
# 1. Install Homebrew + chezmoi
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install chezmoi 1password-cli

# 2. Sign in to 1Password
eval $(op signin)

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

All secrets live in 1Password vault `Dotfiles`:

| Item | Fields |
|------|--------|
| GPG | `key-id` |
| GitHub | `email` |
| GitHub Tokens | `approver-token` |
| GoReleaser | `key` |
| Clerk | `staging`, `preprod`, `prod` |

### Adding a New Secret

```bash
# 1. Create in 1Password
op item create --vault Dotfiles --category "API Credential" \
  --title "ServiceName" "token=your-secret-value"

# 2. Reference in template
chezmoi edit ~/.zshenv
# Add: export SERVICE_TOKEN={{ onepasswordRead "op://Dotfiles/ServiceName/token" | quote }}

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
- [1Password](https://1password.com) account with CLI access
- Access to `Dotfiles` vault

## Documentation

See [HANDBOOK.md](HANDBOOK.md) for detailed setup, configuration, and troubleshooting.

## License

MIT
