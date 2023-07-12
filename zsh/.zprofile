# -*- mode: sh -*-

#
# Executes commands at login pre-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

#
# Editors
#

export ALTERNATE_EDITOR=""
export EDITOR="vim"
export GREPPER="ag"
export PAGER="less"
export GIT_EDITOR="vim"
export SVN_EDITOR="vim"
export VISUAL="${EDITOR}"

#
# Language
#

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the the list of directories that cd searches.
#cdpath=(
#  $cdpath
#)

# Set the list of directories that zsh searches for programs.
path=(
  /usr/local/opt/node@14/bin
  /usr/local/{bin,sbin}
  $HOME/bin
  $GOPATH/bin
  $HOME/.cabal/bin
  $HOME/.nodenv/shims
  $HOME/.config/yarn/global/node_modules/.bin
  $HOME/.pyenv/shims
  $HOME/.rbenv/shims
  ${HOME}/.cargo/bin
  $path
)

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
if (( $+commands[lesspipe.sh] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

#
# Temporary Files
#

if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$USER"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"
if [[ ! -d "$TMPPREFIX" ]]; then
  mkdir -p "$TMPPREFIX"
fi

export PATH="$HOME/.jenv/bin:$PATH"
export PATH="/usr/local/opt/thrift@0.9/bin:$PATH"
