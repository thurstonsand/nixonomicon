# Cache directory for eval command outputs
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$ZSH_CACHE_DIR"

# Caching function for eval commands
# Regenerates cache if: binary updated, cache missing, or args changed
_evalcache() {
  local cmd=$1
  shift
  local cache_file="$ZSH_CACHE_DIR/${cmd##*/}_init.zsh"
  local binary=$(command -v "$cmd" 2>/dev/null)

  # Regenerate if binary is newer, cache missing, or command changed
  if [[ ! -f "$cache_file" ]] || \
     [[ -n "$binary" && "$binary" -nt "$cache_file" ]] || \
     [[ "$cmd $*" != "$(head -1 "$cache_file" 2>/dev/null | sed 's/^# //')" ]]; then
    echo "# $cmd $*" > "$cache_file"
    "$cmd" "$@" >> "$cache_file" 2>/dev/null
    zcompile "$cache_file" 2>/dev/null || true
  fi
  source "$cache_file"
}
