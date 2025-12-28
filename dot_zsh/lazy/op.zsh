__op_lazy_init() {
  if [[ -r "$HOME/.config/op/plugins.sh" ]]; then
    (( $+functions[op] )) && unfunction op 2>/dev/null
    unfunction __op_lazy_init 2>/dev/null
    source "$HOME/.config/op/plugins.sh"
    eval "$(command op completion zsh)"
    (( $+functions[compdef] )) && compdef _op op
  fi
}
