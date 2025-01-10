# If running interactively and zsh exists, switch to zsh
if [[ $- == *i* ]] && command -v zsh >/dev/null 2>&1; then
    export SHELL=$(command -v zsh)
    exec zsh -l
fi
