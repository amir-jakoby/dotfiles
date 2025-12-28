__conda_lazy_init() {
  local conda_base="/opt/homebrew/Caskroom/miniconda/base"
  (( $+functions[conda] )) && unfunction conda 2>/dev/null
  unfunction __conda_lazy_init 2>/dev/null
  if [[ -x "$conda_base/bin/conda" ]]; then
    local __conda_setup
    __conda_setup="$("$conda_base/bin/conda" 'shell.zsh' 'hook' 2>/dev/null)"
    if [[ $? -eq 0 ]]; then
      eval "$__conda_setup"
    elif [[ -f "$conda_base/etc/profile.d/conda.sh" ]]; then
      . "$conda_base/etc/profile.d/conda.sh"
    else
      export PATH="$conda_base/bin:$PATH"
    fi
    unset __conda_setup
  fi
}
