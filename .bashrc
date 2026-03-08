# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

alias dots='/usr/bin/git --git-dir=$HOME/.dots/ --work-tree=$HOME'

# Vi mode
set -o vi

# History
export HISTSIZE=999999999
export HISTFILESIZE=999999999
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT="%F %T "
PROMPT_COMMAND='history -a'

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
