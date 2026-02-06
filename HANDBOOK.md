# Dotfiles Handbook

Complete guide to managing this dotfiles setup.

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   1Password     │────▶│    chezmoi      │────▶│   ~/.*files     │
│ (Dotfiles vault)│     │  (templates)    │     │  (your home)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

**Flow:**
1. chezmoi reads templates from `~/.local/share/chezmoi`
2. Templates pull secrets from 1Password at apply time
3. chezmoi writes final files to your home directory

## Installation

### Fresh Machine

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install chezmoi + 1Password CLI
brew install chezmoi 1password-cli

# Bootstrap 1Password service account
export OP_SERVICE_ACCOUNT_TOKEN="<sawmills-sa-token>"

# Clone and apply
chezmoi init --apply amir-jakoby
```

### Existing Machine (Update)

```bash
chezmoi update  # Pull latest and apply
```

## Configuration

### chezmoi.toml

Located at `~/.config/chezmoi/chezmoi.toml`:

```toml
[onepassword]
  command = "op"
  mode = "service"
  prompt = false

[data]
  machine = "personal"  # or "work"
  email = "amirjak@gmail.com"
  name = "Amir Jakoby"
```

### Machine-Specific Config

Templates can branch on `.machine`:

```
{{ if eq .machine "work" }}
export CORP_PROXY=http://proxy.corp:8080
{{ end }}
```

## Managing Secrets

### Adding a New Secret

1. Create in 1Password (use vault ID to avoid ambiguity with duplicate vault names):
   ```bash
   op item create --vault twc5qlrgqquiaworifv5eczvhy --category "API Credential" \
     --title "ServiceName" "token=your-secret-value"
   ```

2. Reference in template (`.tmpl` file) using vault ID:
   ```bash
   export SERVICE_TOKEN={{ onepasswordRead "op://twc5qlrgqquiaworifv5eczvhy/ServiceName/token" | quote }}
   ```

3. Apply:
   ```bash
   chezmoi apply
   ```

### Listing Secrets

```bash
op item list --vault twc5qlrgqquiaworifv5eczvhy
```

### Updating a Secret

1. Update in 1Password (UI or CLI):
   ```bash
   op item edit "ServiceName" --vault twc5qlrgqquiaworifv5eczvhy "token=new-value"
   ```

2. Re-apply dotfiles:
   ```bash
   chezmoi apply
   ```

### Current Secrets Inventory

| Item | Fields | Used In |
|------|--------|---------|
| GPG | `key-id` | `.gitconfig` |
| GitHub | `email` | `.gitconfig` |
| GitHub Tokens | `approver-token` | `.zshenv` |
| GoReleaser | `key` | `.zshenv` |
| Clerk | `staging`, `preprod`, `prod` | `.zshenv` |

## Managing Files

### Add a New Dotfile

```bash
chezmoi add ~/.newconfig
```

### Convert to Template

```bash
chezmoi cd
mv dot_newconfig dot_newconfig.tmpl
# Edit to add template syntax
```

### Edit a Managed File

```bash
chezmoi edit ~/.zshrc  # Opens in $EDITOR
chezmoi apply          # Apply changes
```

### Remove a File from Management

```bash
chezmoi forget ~/.oldconfig
```

### Make a File Private (mode 0600)

Rename with `private_` prefix:
```bash
mv dot_config private_dot_config
```

## Templating Reference

| Syntax | Description |
|--------|-------------|
| `{{ .name }}` | Variable from chezmoi.toml |
| `{{ .chezmoi.os }}` | OS (`darwin`, `linux`) |
| `{{ .chezmoi.hostname }}` | Machine hostname |
| `{{ .chezmoi.username }}` | Current username |
| `{{ onepasswordRead "op://..." }}` | 1Password secret |
| `{{ onepasswordRead "..." \| quote }}` | Secret with shell quoting |
| `{{ if eq .machine "work" }}...{{ end }}` | Conditional block |

## Common Tasks

### Preview Changes

```bash
chezmoi diff
```

### Dry Run

```bash
chezmoi apply -n
```

### Force Apply (Overwrite Local Changes)

```bash
chezmoi apply --force
```

### View Source Directory

```bash
chezmoi cd
# or
ls ~/.local/share/chezmoi
```

### Check State

```bash
chezmoi status
chezmoi verify
```

## Troubleshooting

### 1Password Service Account Not Set

```bash
# Set the SA token (already exported in ~/.zshenv after first apply)
export OP_SERVICE_ACCOUNT_TOKEN="<sawmills-sa-token>"
chezmoi apply
```

### Template Syntax Error

```bash
chezmoi execute-template < ~/.local/share/chezmoi/dot_zshenv.tmpl
```

### Diff Shows Unexpected Changes

```bash
chezmoi diff ~/.problematic-file
chezmoi merge ~/.problematic-file
```

### Reset to Repo State

```bash
chezmoi apply --force
```

### Debug Mode

```bash
chezmoi apply --verbose --debug
```

## Rollback to GNU Stow

If you need to revert to the pre-chezmoi setup:

```bash
# Remove chezmoi-managed files
chezmoi purge

# Restore Stow setup
cd ~/dotfiles
git checkout pre-chezmoi-backup
stow bin git zsh macos

# Clean up chezmoi
rm -rf ~/.config/chezmoi ~/.local/share/chezmoi
brew uninstall chezmoi
```

## Maintenance

### Update chezmoi

```bash
brew upgrade chezmoi
```

### Sync from Remote

```bash
chezmoi update
# equivalent to: git pull + chezmoi apply
```

### Push Local Changes

```bash
chezmoi cd
git add -A && git commit -m "chore: update dotfiles"
git push
```

## Files Reference

| Source | Target | Description |
|--------|--------|-------------|
| `dot_gitconfig.tmpl` | `~/.gitconfig` | Git config (GPG key, email from 1Password) |
| `dot_zshenv.tmpl` | `~/.zshenv` | Environment variables + secrets |
| `dot_zshrc` | `~/.zshrc` | Zsh interactive shell config |
| `dot_zpreztorc` | `~/.zpreztorc` | Prezto module configuration |
| `private_dot_config/starship.toml` | `~/.config/starship.toml` | Starship prompt theme |
| `private_dot_config/ghostty/config` | `~/.config/ghostty/config` | Ghostty terminal settings |

## Adding More Zsh Components

To add `.zsh/` directory with custom scripts:

```bash
chezmoi add ~/.zsh
```

This creates `dot_zsh/` in the source directory.

## CI/CD Considerations

For automated environments without 1Password:

1. Create a separate non-template config, or
2. Use environment variables as fallback:
   ```
   {{ if env "CI" }}
   export TOKEN=$GITHUB_TOKEN
   {{ else }}
   export TOKEN={{ onepasswordRead "op://twc5qlrgqquiaworifv5eczvhy/..." }}
   {{ end }}
   ```
