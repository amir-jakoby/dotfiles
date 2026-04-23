#!/usr/bin/env bash

set -euo pipefail

cache_dir="${HOME}/.cache/tmux-agent-control"
mkdir -p "$cache_dir"

safe_session_name() {
    printf '%s' "$1" | tr '/:' '__'
}

session_arg="${2:-}"
if [ -z "$session_arg" ] && command -v tmux >/dev/null 2>&1; then
    session_arg="$(tmux display-message -p '#{session_name}' 2>/dev/null || true)"
fi

session_key="$(safe_session_name "${session_arg:-default}")"
pidfile="${cache_dir}/${session_key}.pid"
snapshot_file="${cache_dir}/${session_key}.snapshot.tsv"
events_file="${cache_dir}/${session_key}.events.log"
log_file="${cache_dir}/${session_key}.log"

is_running() {
    [ -f "$pidfile" ] || return 1
    local pid
    pid="$(cat "$pidfile" 2>/dev/null || true)"
    [ -n "$pid" ] || return 1
    kill -0 "$pid" 2>/dev/null
}

write_snapshot() {
    local session_name="$1"
    tmux list-panes -t "$session_name" -F '#{session_name}	#{window_index}	#{pane_index}	#{pane_id}	#{pane_current_command}	#{pane_current_path}	#{pane_title}	#{@agent_name}	#{@agent_state}	#{@agent_display}	#{@agent_updated_at}' > "$snapshot_file" 2>/dev/null || true
}

start_sidecar() {
    local session_name="$1"
    tmux has-session -t "$session_name" >/dev/null 2>&1 || exit 0
    if is_running; then
        exit 0
    fi
    nohup "$0" run "$session_name" >>"$log_file" 2>&1 &
    echo "$!" > "$pidfile"
}

stop_sidecar() {
    if ! is_running; then
        rm -f "$pidfile"
        exit 0
    fi
    local pid
    pid="$(cat "$pidfile")"
    kill "$pid" 2>/dev/null || true
    rm -f "$pidfile"
}

summary() {
    local session_name="$1"
    if is_running; then
        printf 'control: on (%s)' "$session_name"
    else
        printf 'control: off'
    fi
}

status_view() {
    local session_name="$1"
    while true; do
        clear
        printf 'tmux control-mode sidecar  session=%s  %s  %s\n\n' "$session_name" "$(summary "$session_name")" "$(date '+%Y-%m-%d %H:%M:%S')"
        if [ -s "$snapshot_file" ]; then
            printf '%-10s %-16s %-8s %-20s %-26s %-20s\n' "pane" "cmd" "state" "path" "display" "updated"
            printf '%-10s %-16s %-8s %-20s %-26s %-20s\n' "----------" "----------------" "--------" "--------------------" "--------------------------" "--------------------"
            while IFS=$'\t' read -r session win pane pane_id pane_cmd pane_path pane_title agent state display updated_at; do
                printf '%-10s %-16s %-8s %-20s %-26s %-20s\n' \
                    "${session}:${win}.${pane}" \
                    "${pane_cmd:0:16}" \
                    "${state:--}" \
                    "${pane_path:0:20}" \
                    "${display:0:26}" \
                    "${updated_at:0:20}"
            done < "$snapshot_file"
        else
            printf 'No snapshot yet.\n'
        fi
        printf '\nq quit  s start  x stop  r refresh\n'
        if ! IFS= read -rsn1 -t 1 key; then
            continue
        fi
        case "$key" in
            q|Q) exit 0 ;;
            s|S) start_sidecar "$session_name" ;;
            x|X) stop_sidecar ;;
            r|R) write_snapshot "$session_name" ;;
        esac
    done
}

run_sidecar() {
    local session_name="$1"
    local in_fifo out_fifo tmux_pid
    trap 'rm -f "$pidfile"' EXIT

    write_snapshot "$session_name"

    in_fifo="$(mktemp -u "${cache_dir}/${session_key}.in.XXXX")"
    out_fifo="$(mktemp -u "${cache_dir}/${session_key}.out.XXXX")"
    mkfifo "$in_fifo" "$out_fifo"
    trap 'rm -f "$pidfile" "$in_fifo" "$out_fifo"' EXIT

    tmux -C attach-session -t "$session_name" <"$in_fifo" >"$out_fifo" 2>/dev/null &
    tmux_pid="$!"

    exec 3>"$in_fifo"
    exec 4<"$out_fifo"

    printf 'refresh-client -f no-output,wait-exit\n' >&3
    printf "%s\n" "refresh-client -B 'agent:%*:#{pane_id}\t#{pane_current_command}\t#{pane_current_path}\t#{pane_title}\t#{@agent_name}\t#{@agent_state}\t#{@agent_display}\t#{@agent_updated_at}'" >&3

    while IFS= read -r line <&4; do
        printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$line" >> "$events_file"
        case "$line" in
            %subscription-changed\ agent\ *|%window-*|%layout-change*|%session-window-changed*|%session-renamed*|%sessions-changed*)
                write_snapshot "$session_name"
                ;;
            %exit*)
                break
                ;;
        esac
    done

    printf '\n' >&3 || true
    wait "$tmux_pid" 2>/dev/null || true
}

command_name="${1:-status}"

case "$command_name" in
    start|ensure) start_sidecar "$session_arg" ;;
    stop) stop_sidecar ;;
    run) run_sidecar "$session_arg" ;;
    summary) summary "$session_arg" ;;
    status) status_view "$session_arg" ;;
    refresh) write_snapshot "$session_arg" ;;
    *) exit 1 ;;
esac
