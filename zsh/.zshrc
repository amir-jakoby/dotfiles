# -*- mode: sh -*-

#
# Executes commands at the start of an interactive session.
#
# Author:
#   Nathan Houle <nathan@nathanhoule.com>
#
# Credit to:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Zach Holman <zach@zachholman.com>
#

function {
  export DOTFILES="${HOME}/.dotfiles"
  #
  # Zprezto
  #

  # Load zprezto if it's installed
  if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
  fi

  for config (~/.zsh/*.zsh) source "${config}"
}

# Customize to your needs...
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
source <(kubectl completion zsh)
source <(helm completion zsh)
source <(oc completion zsh)

#source <(pipenv --completion)  # this is slow so I just pasted the result here:
#compdef pipenv
_pipenv() {
  eval $(env COMMANDLINE="${words[1,$CURRENT]}" _PIPENV_COMPLETE=complete-zsh  pipenv)
}
if [[ "$(basename ${(%):-%x})" != "_pipenv" ]]; then
  autoload -U compinit && compinit
  compdef _pipenv pipenv
fi
