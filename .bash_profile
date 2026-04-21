[[ -x "$(which wslinfo)" ]] && alias open="cmd.exe /C start &>/dev/null" 

alias gs="git status"
alias gl="git log"
alias gup="git fetch upstream main && git rebase upstream main"
alias gfix="git commit --fixup HEAD && git rebase --autosquash HEAD~2"
alias gc="git commit"

gpr() {
	open "https://github.com/$(git remote get-url upstream | sed 's@.*:\(.*\)\.git@\1@')/compare/main...tayheau:$(basename `git rev-parse --show-toplevel`):$(git branch --show-current)?expand=1"
}


shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

PS1='$(err=$?; [[ $err -ne 0 ]] && printf "\[\e[41m\e[1m\]";echo "\w\[\e[0m\]";)$(git rev-parse --abbrev-ref HEAD 2>/dev/null | sed "s@\(.*\)@ \[\e[32m\](\1)\[\e[0m\]@";)$ '

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
