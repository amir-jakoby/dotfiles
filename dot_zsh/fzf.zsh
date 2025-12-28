# -*- mode: sh -*-

#
# fzf (https://github.com/junegunn/fzf) configuration.
#

# Homebrew fzf installation
if [[ -d /opt/homebrew/opt/fzf ]]; then
  # Key bindings (Ctrl+R history, Ctrl+T files, Alt+C cd)
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

  # Fuzzy completion (type **<TAB>)
  source /opt/homebrew/opt/fzf/shell/completion.zsh
fi

# fzf options
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Use fd if available (faster than find)
if command -v fd &> /dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi
