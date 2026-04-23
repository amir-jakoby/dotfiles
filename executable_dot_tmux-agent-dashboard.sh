#!/usr/bin/env bash

set -euo pipefail

metadata_cmd="${HOME}/bin/tmux-agent-metadata"
control_cmd="${HOME}/.tmux-agent-control-mode.sh"

truncate() {
    local value="$1"
    local max_len="$2"
    if [ "${#value}" -le "$max_len" ]; then
        printf '%s' "$value"
    else
        printf '%s' "${value:0:max_len-3}..."
    fi
}

control_status() {
    local session_name
    session_name="$(tmux display-message -p '#{session_name}' 2>/dev/null || true)"
    "$control_cmd" ensure "$session_name" >/dev/null 2>&1 || true
    "$control_cmd" summary "$session_name" 2>/dev/null || printf 'control: off'
}

render() {
    clear
    printf 'Agent Dashboard  %s  %s\n\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$(control_status)"
    printf '%-10s %-12s %-8s %-18s %-16s %-24s %-20s\n' "pane" "agent" "state" "repo" "cmd" "display" "updated"
    printf '%-10s %-12s %-8s %-18s %-16s %-24s %-20s\n' "----------" "------------" "--------" "------------------" "----------------" "------------------------" "--------------------"

    "$metadata_cmd" list --agents-only | while IFS=$'\t' read -r session win pane pane_id pane_active window_active pane_cmd pane_path pane_title agent state project branch display updated_at updated_epoch resume_cmd; do
        local repo
        repo="$project"
        if [ "$repo" = "-" ]; then
            repo=""
        fi
        if [ -n "$branch" ] && [ "$branch" != "-" ] && [ "$branch" != "main" ] && [ "$branch" != "master" ]; then
            repo="${repo}:${branch}"
        fi

        printf '%-10s %-12s %-8s %-18s %-16s %-24s %-20s\n' \
            "$(truncate "${session}:${win}.${pane}" 10)" \
            "$(truncate "$agent" 12)" \
            "$(truncate "$state" 8)" \
            "$(truncate "${repo:--}" 18)" \
            "$(truncate "$pane_cmd" 16)" \
            "$(truncate "$display" 24)" \
            "$(truncate "${updated_at:--}" 20)"
    done

    printf '\nq quit  a picker  c control  r refresh\n'
}

while true; do
    render
    if ! IFS= read -rsn1 -t 1 key; then
        continue
    fi
    case "$key" in
        q|Q) exit 0 ;;
        a|A) exec "${HOME}/.tmux-agent-picker.sh" ;;
        c|C) exec "$control_cmd" status "$(tmux display-message -p '#{session_name}' 2>/dev/null || true)" ;;
        r|R) ;;
    esac
done
