typeset -U path cdpath fpath manpath
autoload -U compinit && compinit

# History Settings
HISTSIZE=1000
SAVEHIST=10000
HISTFILE=$HOME/.zsh_history

# Shell options and initialization
setopt HIST_FCNTL_LOCK
unsetopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
unsetopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY
setopt autocd
setopt EXTENDED_GLOB       # treat #, ~, and ^ as part of patterns for filename generation
setopt INTERACTIVE_COMMENTS # allow comments in interactive shells
setopt NOTIFY              # report the status of background jobs immediately

# Program Inits
eval "$(fzf --zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd j)"

# aliases
alias -- eza="eza --icons auto --git"
alias -- la="eza -a"
alias -- ll="eza -l"
alias -- lla="eza -la"
alias -- ls="eza"
alias -- lt="eza --tree"
alias -- ping="prettyping"
alias -- top="htop"