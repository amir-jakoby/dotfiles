# -*- mode: sh -*-

#
# Helper functions that don't belong elsewhere.
#
# Author:
#   Nathan Houle <nathan@nathanhoule.com>
#

# Launch a static server in the current directory
alias http-serve=x
unalias http-serve
http-serve() {
  local port=${1:-8080}

  if [[ -x $(which http-server) ]]; then
    http-server -p $port
  else
    python -m SimpleHTTPServer $port
  fi
}

# Keep a process running, restarting it if it crashes
always() {
  until $1; do
    echo "$1 died with exit code $?. Respawning..." >&2
    sleep 1
  done
}

goroot() {
  cd "$(git rev-parse --show-toplevel)"
}

# Profile interactive shell startup and show top offenders.
zprof-startup() {
  local tmp_base tmp_rc
  tmp_base=$(mktemp -d)
  tmp_rc="$tmp_base/.zshrc"
  cat <<'EOF' > "$tmp_rc"
zmodload zsh/zprof
export ZDOTDIR="$HOME"
source "$HOME/.zshrc"
zprof
EOF
  ZDOTDIR="$tmp_base" zsh -i -c exit | sed -n '1,40p'
  rm -rf "$tmp_base"
}

# Benchmark startup time and append results to a log.
zstartup-benchmark() {
  local runs=${1:-5}
  local log_dir=''
  local log_file=''
  local lines
  local -a candidates
  candidates=("${XDG_CACHE_HOME:-$HOME/.cache}/zsh" "${TMPDIR:-/tmp}/zsh")

  for dir in "${candidates[@]}"; do
    /bin/mkdir -p "$dir" 2>/dev/null || continue
    if /usr/bin/touch "$dir/startup-times.log" 2>/dev/null; then
      log_dir="$dir"
      log_file="$dir/startup-times.log"
      break
    fi
  done

  if [[ -z "$log_dir" ]]; then
    print -u2 -- "zstartup-benchmark: failed to create log file"
    return 1
  fi
  print -r -- "## $(date -u +\"%Y-%m-%dT%H:%M:%SZ\") runs=$runs" >> "$log_file" || return 1
  for _ in {1..$runs}; do
    /usr/bin/time -p command zsh -i -c exit 2>>"$log_file"
  done
  lines=$((runs * 3 + 1))
  tail -n "$lines" "$log_file"
}
