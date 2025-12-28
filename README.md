# dotfiles

Personal macOS environment managed with [chezmoi](https://chezmoi.io) and [1Password](https://1password.com).

## Quick Start (New Machine)

```bash
# 1. Install prerequisites
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install chezmoi 1password-cli

# 2. Sign in to 1Password
eval $(op signin)

# 3. Initialize dotfiles
chezmoi init --apply amir-jakoby
```

Done. All configs and secrets are now in place.

## Daily Usage

| Command | Description |
|---------|-------------|
| `chezmoi apply` | Apply latest dotfiles |
| `chezmoi update` | Pull & apply from repo |
| `chezmoi edit ~/.zshrc` | Edit managed file |
| `chezmoi add ~/.newfile` | Track a new file |
| `chezmoi diff` | Preview pending changes |

## Structure

```
.
├── dot_gitconfig.tmpl      # Git config (secrets from 1Password)
├── dot_zshenv.tmpl         # Environment variables + secrets
├── dot_zshrc               # Zsh config
├── dot_zpreztorc           # Prezto modules
└── private_dot_config/
    ├── starship.toml       # Starship prompt
    └── ghostty/config      # Ghostty terminal
```

## Secrets

All secrets live in 1Password vault `Dotfiles`. Templates reference them via:

```
{{ onepasswordRead "op://Dotfiles/Item/field" }}
```

| Item | Fields |
|------|--------|
| GPG | `key-id` |
| GitHub | `email` |
| GitHub Tokens | `approver-token` |
| GoReleaser | `key` |
| Clerk | `staging`, `preprod`, `prod` |

## Prerequisites

- macOS
- [Homebrew](https://brew.sh)
- [1Password CLI](https://developer.1password.com/docs/cli)
- Access to `Dotfiles` vault in 1Password

## Documentation

See [HANDBOOK.md](HANDBOOK.md) for detailed setup, configuration, and troubleshooting.

## License

MIT
