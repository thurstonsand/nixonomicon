typeset -U path cdpath fpath manpath
autoload -U compinit && compinit

# History Settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=/home/thurstonsand/.zsh_history

# Shell options and initialization
setopt HIST_FCNTL_LOCK
  setopt "$opt"
  unsetopt "$opt"
setopt EXTENDED_GLOB       # treat #, ~, and ^ as part of patterns for filename generation
setopt INTERACTIVE_COMMENTS # allow comments in interactive shells
setopt NOTIFY              # report the status of background jobs immediately

# Program Inits
eval "$(fzf --zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd j)"

# aliases
alias -- codex="npx @openai/codex"
alias -- eza="eza --icons auto --git"
alias -- gemini="npx @google/gemini-cli"
alias -- la="eza -a"
alias -- ll="eza -l"
alias -- lla="eza -la"
alias -- ls="eza"
alias -- lt="eza --tree"
alias -- openskills="npx openskills"
alias -- ping="prettyping"
alias -- top="htop"