export PS1="\[\e[41m\]\w\[\e[0m\]"

alias gs="git status"
alias gl="git log"
alias gup="git pull --rebase upstream main"
alias gc="git commit"


shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

PS1='$(err=$?; [[ $err -ne 0 ]] && printf "\[\e[41m\e[1m\]";echo "\w\[\e[0m\]";)$(git rev-parse --abbrev-ref HEAD 2>/dev/null | sed "s@\(.*\)@ (\1)@")$ '

TYPST_PACKAGE_PATH=$(typst info 2>&1 | awk -F'  +' '/^  Package path/{print $NF}')

# if [ -n "$BASH_VERSION" ]; then
#     # include .bashrc if it exists
#     if [ -f "$HOME/.bashrc" ]; then
# 	. "$HOME/.bashrc"
#     fi
# fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
