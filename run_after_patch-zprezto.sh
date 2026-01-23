#!/bin/bash
# Patch zprezto completion format for fzf-tab compatibility
# Replaces zsh %F{yellow} codes with ANSI \e[33m (yellow) that fzf renders
sed -i.bak 's/%F{yellow}-- %d --%f/\\x1b[33m-- %d --\\x1b[0m/' ~/.zprezto/modules/completion/init.zsh 2>/dev/null || true
