# -*- mode: sh -*-

#
# Modern CLI tools integration (2025)
#

# ============================================================================
# zoxide - smarter cd (https://github.com/ajeetdsouza/zoxide)
# ============================================================================
# Usage:
#   z foo       - cd to highest ranked directory matching foo
#   z foo bar   - cd to directory matching foo and bar
#   zi foo      - interactive selection with fzf
#   z -         - cd to previous directory
#   zoxide query -ls  - list all tracked directories
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# ============================================================================
# atuin - shell history sync (https://github.com/atuinsh/atuin)
# ============================================================================
# Usage:
#   Ctrl+R      - search history (replaces default)
#   atuin search foo  - search for 'foo' in history
#   atuin sync        - sync history across machines
#   atuin stats       - show history statistics
#   atuin login       - login for cross-machine sync
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# ============================================================================
# eza - modern ls (https://github.com/eza-community/eza)
# ============================================================================
# Usage:
#   l           - list files
#   ll          - long list with details
#   la          - list all including hidden
#   lt          - tree view
#   lta         - tree view with hidden files
if command -v eza &> /dev/null; then
  alias l='eza'
  alias ls='eza'
  alias ll='eza -l --git --icons'
  alias la='eza -la --git --icons'
  alias lt='eza --tree --level=2 --icons'
  alias lta='eza --tree --level=2 -a --icons'

fi

# ============================================================================
# delta - better git diffs (https://github.com/dandavison/delta)
# ============================================================================
# Usage:
#   Configured via .gitconfig (already set up)
#   git diff    - shows beautiful diffs automatically
#   delta file1 file2  - diff any two files
# Note: Add to .gitconfig:
#   [core]
#     pager = delta
#   [interactive]
#     diffFilter = delta --color-only

# ============================================================================
# mise - universal version manager (https://github.com/jdx/mise)
# ============================================================================
# Usage:
#   mise install node@20   - install Node.js 20
#   mise use node@20       - use in current project
#   mise global node@20    - set global default
#   mise ls                - list installed versions
#   mise ls-remote python  - list available versions
#   mise activate zsh      - (already done below)
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# ============================================================================
# lazygit - terminal git UI (https://github.com/jesseduffield/lazygit)
# ============================================================================
# Usage:
#   lg          - open lazygit in current repo
#   Navigation: hjkl or arrow keys
#   Space       - stage/unstage file
#   c           - commit
#   p           - push
#   ?           - show keybindings
if command -v lazygit &> /dev/null; then
  alias lg='lazygit'
fi

# ============================================================================
# yazi - terminal file manager (https://github.com/sxyazi/yazi)
# ============================================================================
# Usage:
#   y           - open yazi
#   Navigation: hjkl or arrow keys
#   Enter       - open file/directory
#   q           - quit
#   y           - copy file
#   p           - paste file
#   d           - delete file
#   /           - search
# Wrapper to cd to directory on exit:
if command -v yazi &> /dev/null; then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi
