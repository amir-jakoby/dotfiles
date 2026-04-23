#!/usr/bin/env bash

set -euo pipefail

INPUT=""
if [ ! -t 0 ]; then
    INPUT=$(cat 2>/dev/null || true)
fi

EVENT=""
CWD=""
HOOK_EVENT=""

if [ -n "$INPUT" ] && printf '%s' "$INPUT" | jq -e '.hook_event_name?' >/dev/null 2>&1; then
    HOOK_EVENT=$(printf '%s' "$INPUT" | jq -r '.hook_event_name // empty')
    EVENT="$HOOK_EVENT"
    CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty')
else
    EVENT="${1:-}"
    CWD="${2:-}"
fi

[ -n "$EVENT" ] || exit 0

PANE_ID="${TMUX_PANE:-}"
[ -n "$PANE_ID" ] || PANE_ID=$(tmux display-message -p '#{pane_id}' 2>/dev/null || echo "")
[ -n "$PANE_ID" ] || exit 0

resolve_cwd() {
    local dir="$1"

    case "$dir" in
        ""|/|*/.claude/*|*/memory/*|*/memories/*|*/.config/*) ;;
        *)
            if [ -d "$dir" ]; then
                printf '%s\n' "$dir"
                return
            fi
            ;;
    esac

    tmux display-message -t "$PANE_ID" -p '#{pane_current_path}' 2>/dev/null || true
}

resolve_essence() {
    local dir="$1"
    local current project branch essence

    essence=""
    if [ -n "$dir" ] && [ "$dir" != "/" ]; then
        project=$(basename "$dir")
        branch=$(git -C "$dir" branch --show-current 2>/dev/null || true)
        if [ -n "$branch" ] && [ "$branch" != "main" ] && [ "$branch" != "master" ]; then
            essence="${project}:${branch}"
        else
            essence="$project"
        fi
    fi

    if [ -z "$essence" ]; then
        current=$(tmux display-message -t "$PANE_ID" -p '#W' 2>/dev/null || true)
        essence=$(printf '%s' "$current" | sed -E 's/^(◐|◓|◑|◒|✓|✅|⏳|⌛|✔️|⚠️)[[:space:]]+//' | sed -E 's/^(Bash|Edit|Read|Write|Grep|Glob|Agent|WebSearch|WebFetch)[[:space:]]+//')
        essence="${essence# }"
    fi

    if [ -z "$essence" ] || [ "$essence" = "/" ]; then
        essence=$(tmux display-message -t "$PANE_ID" -p '#S' 2>/dev/null || echo "codex")
    fi

    if [ ${#essence} -gt 30 ]; then
        essence="${essence:0:27}..."
    fi

    printf '%s\n' "$essence"
}

STATE=""
case "$EVENT" in
    UserPromptSubmit|start|session-start|turn-start|working)
        STATE="running"
        ;;
    permission*|approve*|needs-input|input-required|ask-user)
        STATE="needs-input"
        ;;
    Stop|agent-turn-complete|complete|done|stop|error|fail*)
        STATE="done"
        ;;
esac

RESOLVED_CWD=$(resolve_cwd "$CWD")
ESSENCE=$(resolve_essence "$RESOLVED_CWD")

METADATA_SCRIPT="$HOME/bin/tmux-agent-metadata"
if [ -x "$METADATA_SCRIPT" ] && [ -n "$STATE" ]; then
    "$METADATA_SCRIPT" set --pane "$PANE_ID" --agent codex --state "$STATE" --cwd "$RESOLVED_CWD" --event "$EVENT" >/dev/null 2>&1 || true
fi

case "$HOOK_EVENT" in
    SessionStart)
        tmux rename-window -t "$PANE_ID" "$ESSENCE" 2>/dev/null || true
        ;;
    UserPromptSubmit)
        tmux rename-window -t "$PANE_ID" "⌛ $ESSENCE" 2>/dev/null || true
        ;;
    Stop)
        tmux rename-window -t "$PANE_ID" "✔️ $ESSENCE" 2>/dev/null || true
        ;;
esac

if [ -z "${TMUX:-}" ]; then
    TMUX=$(tmux display-message -p '#{socket_path},#{pid},#{session_id}' 2>/dev/null || true)
    export TMUX
fi

PLUGIN_DIR="${TMUX_AGENT_INDICATOR_DIR:-$HOME/.tmux/plugins/tmux-agent-indicator}"
STATE_SCRIPT="$PLUGIN_DIR/scripts/agent-state.sh"
if [ -n "$STATE" ] && [ -n "${TMUX:-}" ] && [ -x "$STATE_SCRIPT" ]; then
    TMUX_PANE="$PANE_ID" bash "$STATE_SCRIPT" --agent codex --state "$STATE"
fi

exit 0
