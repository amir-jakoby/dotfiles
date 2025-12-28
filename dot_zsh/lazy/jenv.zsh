__jenv_lazy_init() {
  if command -v jenv >/dev/null; then
    (( $+functions[jenv] )) && unfunction jenv 2>/dev/null
    unfunction __jenv_lazy_init 2>/dev/null
    eval "$(command jenv init -)"
  fi
}
