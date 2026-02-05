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

# fzf-tab: Replace zsh's default completion menu with fzf
if [[ -f ~/.zsh/plugins/fzf-tab/fzf-tab.plugin.zsh ]]; then
  source ~/.zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
  
  # Basic settings
  zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse
  zstyle ':fzf-tab:*' prefix ''  # Remove · prefix
  
  # Override zprezto's %F{yellow} format with plain text (fzf doesn't render zsh prompt codes)
  zstyle ':completion:*:descriptions' format '-- %d --'
  zstyle ':completion:*:messages' format '-- %d --'
  zstyle ':completion:*:warnings' format '-- no matches --'

  # Sawmills palette for sm completions
  zstyle ':fzf-tab:complete:sm:*' fzf-flags --height=50% --layout=reverse --border --ansi \
    '--color=fg:#EDEDED,bg:#0B0E14,hl:#E879F9,fg+:#FFFFFF,bg+:#1B2230,hl+:#E879F9' \
    '--color=info:#7C5CFF,border:#7C5CFF,prompt:#7C5CFF,pointer:#22C55E,marker:#E879F9,spinner:#7C5CFF,header:#7C5CFF'

  zstyle ':completion:*:sm:*:descriptions' format '%F{#7C5CFF}» %d%f'
  zstyle ':completion:*:sm:*:messages' format '%F{#E879F9}%d%f'
  zstyle ':completion:*:sm:*:warnings' format '%F{#FF6E66}%d%f'
  zstyle ':completion:*:sm:*:corrections' format '%F{#E879F9}%d%f'
fi
