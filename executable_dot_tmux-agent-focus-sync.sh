#!/usr/bin/env bash

set -euo pipefail

pane_id="${1:-}"
window_id="${2:-}"

[ -n "$pane_id" ] || exit 0
[ -n "$window_id" ] || exit 0

plugin_script="${HOME}/.tmux/plugins/tmux-agent-indicator/scripts/pane-focus-in.sh"
reconcile_script="${HOME}/.codex/hooks/tmux-reconcile-current-pane.sh"

if [ -x "$plugin_script" ]; then
    "$plugin_script" "$pane_id" "$window_id" >/dev/null 2>&1 || true
fi

if [ -x "$reconcile_script" ]; then
    "$reconcile_script" "$pane_id" "$window_id" >/dev/null 2>&1 || true
fi
