#!/usr/bin/env bash

set -euo pipefail

if ! command -v tmux >/dev/null 2>&1; then
    exit 0
fi

pane_id=$(tmux display-message -p '#{pane_id}' 2>/dev/null || true)
[ -n "$pane_id" ] || exit 0

state=$(tmux show-environment -g "TMUX_AGENT_PANE_${pane_id}_STATE" 2>/dev/null | sed 's/^[^=]*=//' || true)
agent=$(tmux show-environment -g "TMUX_AGENT_PANE_${pane_id}_AGENT" 2>/dev/null | sed 's/^[^=]*=//' || true)
[ "$state" = "running" ] || exit 0
[ "$agent" = "codex" ] || exit 0

pane_cmd=$(tmux display-message -p -t "$pane_id" '#{pane_current_command}' 2>/dev/null || true)
case "$pane_cmd" in
    codex|codex-aarch64-a) ;;
    *) exit 0 ;;
esac

pane_text=$(tmux capture-pane -t "$pane_id" -p -S -80 2>/dev/null | tail -n 80 || true)
printf '%s\n' "$pane_text" | grep -q 'Working (' && exit 0
printf '%s\n' "$pane_text" | grep -qi 'esc to interrupt' && exit 0
printf '%s\n' "$pane_text" | grep -q '^› ' || exit 0

current_name=$(tmux display-message -p -t "$pane_id" '#W' 2>/dev/null || true)
cleaned_name=$(printf '%s' "$current_name" | sed -E 's/^(◐|◓|◑|◒|✓|✅|⏳|⌛|✔️|⚠️)[[:space:]]+//' | sed -E 's/^(Bash|Edit|Read|Write|Grep|Glob|Agent|WebSearch|WebFetch)[[:space:]]+//')
cleaned_name="${cleaned_name# }"
if [ -z "$cleaned_name" ]; then
    cleaned_name=$(tmux display-message -p -t "$pane_id" '#{session_name}' 2>/dev/null || echo "codex")
fi

tmux rename-window -t "$pane_id" "✔️ $cleaned_name" 2>/dev/null || true

if [ -z "${TMUX:-}" ]; then
    TMUX=$(tmux display-message -p '#{socket_path},#{pid},#{session_id}' 2>/dev/null || true)
    export TMUX
fi

plugin_dir="${TMUX_AGENT_INDICATOR_DIR:-$HOME/.tmux/plugins/tmux-agent-indicator}"
state_script="$plugin_dir/scripts/agent-state.sh"
[ -x "$state_script" ] || exit 0
TMUX_PANE="$pane_id" bash "$state_script" --agent codex --state done >/dev/null 2>&1 || true
