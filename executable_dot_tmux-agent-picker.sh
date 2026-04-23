#!/usr/bin/env bash

set -euo pipefail

metadata_cmd="${HOME}/bin/tmux-agent-metadata"

if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for the agent picker"
    exit 1
fi

selection="$(
    "$metadata_cmd" list --agents-only |
    fzf \
        --layout=reverse \
        --height=100% \
        --border \
        --prompt='agent> ' \
        --delimiter=$'\t' \
        --with-nth=1,2,3,6,7,10,11,12,13,14,15 \
        --header=$'enter jump  ctrl-r resume  ctrl-o open cwd  ctrl-c close' \
        --preview-window='right:60%' \
        --preview='tmux capture-pane -t {4} -p -S -40 2>/dev/null' \
        --bind='ctrl-r:execute-silent(tmux new-window -d -c {8} "{17}")+accept' \
        --bind='ctrl-o:execute-silent(tmux new-window -c {8})+accept'
)" || exit 0

[ -n "$selection" ] || exit 0

IFS=$'\t' read -r session win pane pane_id pane_active window_active pane_cmd pane_path pane_title agent state project branch display updated_at updated_epoch resume_cmd <<< "$selection"

tmux switch-client -t "$session"
tmux select-window -t "${session}:${win}"
tmux select-pane -t "$pane_id"
