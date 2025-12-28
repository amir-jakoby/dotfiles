__pyenv_lazy_init() {
  if command -v pyenv >/dev/null; then
    (( $+functions[pyenv] )) && unfunction pyenv 2>/dev/null
    unfunction __pyenv_lazy_init 2>/dev/null
    eval "$(command pyenv init -)"
  fi
}
