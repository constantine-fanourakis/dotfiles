# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

alias dots='/usr/bin/git --git-dir=$HOME/.dots/ --work-tree=$HOME'

# Vi mode
set -o vi

# History
export HISTSIZE=999999999
export HISTFILESIZE=999999999
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT="%F %T "
PROMPT_COMMAND='history -a'

export PATH="$HOME/.local/bin:$PATH"

eval "$(fzf --bash)"
eval "$(starship init bash)"
