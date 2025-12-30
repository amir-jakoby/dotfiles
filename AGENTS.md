# PROJECT KNOWLEDGE BASE

**Generated:** Tue Dec 30 2025
**Commit:** 796b310
**Branch:** main

## OVERVIEW

Personal dotfiles repository managed by **Chezmoi**. Configures Zsh (Prezto), Ghostty, Starship, and system utilities.
**Core Stack:** Chezmoi, Zsh, Prezto, Homebrew.

## STRUCTURE

```
.
├── dot_zsh/            # Zsh configuration modules
│   ├── lazy/           # Lazy-loaded zsh plugins (conda, jenv, etc)
│   └── functions.zsh   # Custom shell functions
├── executable_bin/     # Custom scripts (docker cleanups, git helpers)
├── private_dot_config/ # Application configs (ghostty, starship)
├── .chezmoi.toml.tmpl  # Main Chezmoi config template
└── dot_zshrc           # Main zsh entry point
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add zsh plugin | `dot_zsh/lazy/` | Create .zsh file, lazy load in .zshrc |
| Update aliases | `dot_zsh/aliases.zsh` | Keep categorized |
| Add script | `executable_bin/` | Ensure executable permissions |
| Edit app config | `private_dot_config/{app}/` | Check for .tmpl extensions |

## CONVENTIONS

- **Chezmoi**: NEVER edit target files directly (~/.zshrc). Edit source files (`dot_zshrc`) then `chezmoi apply`.
- **Templates**: Files ending in `.tmpl` use Go template syntax.
- **Secrets**: Use `private_` prefix for sensitive configs (not encrypted in this repo, careful).
- **Zsh Performance**: Defer initialization. Use `dot_zsh/lazy/` for heavy tools (conda, nvm).

## GLOBAL RULES (Merged)

- **Owner**: amir-jakoby @ Sawmills.ai.
- **Commits**: Conventional Commits (`feat|fix|refactor|ci|docs`).
- **PRs**: Use `gh pr view/diff` (no URLs).
- **Flow**: Atomic commits. Safe by default. No destructive ops without explicit request.

## COMMANDS

```bash
chezmoi apply           # Apply changes to local system
chezmoi diff            # Check pending changes
chezmoi update          # Pull and apply
chmod +x executable_bin/* # Ensure scripts are executable
```

## NOTES

- **Ghostty**: Config in `private_dot_config/ghostty/config`.
- **Prezto**: Submodules in `zsh/.zprezto`.
- **Dependencies**: `run_onchange_brew-bundle.sh.tmpl` manages Homebrew packages.
