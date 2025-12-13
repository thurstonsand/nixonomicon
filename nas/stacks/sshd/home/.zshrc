# Portable zshrc - extracted from NixOS configuration
# Works on any system with zsh and the required tools installed

typeset -U path cdpath fpath manpath

# Use emacs keymap as the default.
bindkey -e

autoload -Uz compinit
# Only regenerate .zcompdump if it's older than 24 hours
# The glob qualifier (mh+24) checks for files modified more than 24 hours ago
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qNmh+24) ]]; then
  compinit
else
  compinit -C  # Skip security check for faster startup
fi

# Autosuggestions (install zsh-autosuggestions package)
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history)

# History options should be set in .zshrc and after oh-my-zsh sourcing.
# See https://github.com/nix-community/home-manager/issues/177.
HISTSIZE="10000"
SAVEHIST="10000"

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK

# Enabled history options
enabled_opts=(
  HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY autocd
)
for opt in "${enabled_opts[@]}"; do
  setopt "$opt"
done
unset opt enabled_opts

# Disabled history options
disabled_opts=(
  APPEND_HISTORY EXTENDED_HISTORY HIST_FIND_NO_DUPS HIST_IGNORE_ALL_DUPS
  HIST_SAVE_NO_DUPS
)
for opt in "${disabled_opts[@]}"; do
  unsetopt "$opt"
done
unset opt disabled_opts

# Initialize tools with caching
# Interactive-only tools
if [[ -o interactive ]]; then
  _evalcache fzf --zsh
  _evalcache zoxide init zsh --cmd cd
  if [[ $TERM != "dumb" ]]; then
    _evalcache starship init zsh
  fi
fi
_evalcache direnv hook zsh

# Extended glob operators
setopt EXTENDED_GLOB       # treat #, ~, and ^ as part of patterns for filename generation

# Input/Output
setopt INTERACTIVE_COMMENTS # allow comments in interactive shells

# Job Control
setopt NOTIFY              # report the status of background jobs immediately

# Extra key bindings
bindkey "^[[3~" delete-char
# bindkey "^[[3;9~" kill-line
bindkey "^U" backward-kill-line

alias -- codex='npx -y @openai/codex'
alias -- eza='eza --icons auto --git'
alias -- gemini='npx -y @google/gemini-cli'
alias -- la='eza -a'
alias -- lg=lazygit
alias -- ll='eza -l'
alias -- lla='eza -la'
alias -- ls=eza
alias -- lt='eza --tree'
alias -- openskills='npx -y openskills'
alias -- ping=prettyping
alias -- top=htop
# Syntax highlighting (install zsh-syntax-highlighting package)
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS+=(main brackets pattern line cursor root)
