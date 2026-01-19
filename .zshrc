export SHELL=/bin/zsh

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git

precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST
# PROMPT='%F{green}%*%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '
setopt PROMPT_SUBST
# Disable virtualenv's default prompt modification
export VIRTUAL_ENV_DISABLE_PROMPT=1
# PROMPT='%F{green}%*%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '
PROMPT='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }%F{green}%*%f %F{blue}%1~%f %F{red}${vcs_info_msg_0_}%f$ '

#ssh 1pass
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Aliases
alias vim="nvim"
alias ll="ls -l"
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# bindkey '\e[H' beginning-of-line
# bindkey '\e[F' end-of-line

# fix title
DISABLE_AUTO_TITLE="true"
function stitle() { echo -en "\e]2;$@\a" }

export EDITOR=/opt/homebrew/bin/nvim

# History
#set history size
export HISTSIZE=999999999
#save history after logout
export SAVEHIST=$HISTSIZE
#history file
export HISTFILE=~/.zhistory
#append into history file
setopt INC_APPEND_HISTORY
#save only one command
setopt HIST_IGNORE_DUPS
#add timestamp for each entry
setopt EXTENDED_HISTORY

. "$HOME/.local/bin/env"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/constantine/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# zsh-vi-mode plugin
ZVM_INIT_MODE=sourcing # Do the initialization when the script is sourced
ZSH_PLUGINS="${HOME}/.zsh/plugins"
ZVM_DIR="${ZSH_PLUGINS}/zsh-vi-mode"
source "$ZVM_DIR/zsh-vi-mode.plugin.zsh"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
export PATH=/Users/constantine/Library/Python/3.9/bin:"$PATH"
export PATH="$(brew --prefix)/opt/python@3/libexec/bin:$PATH"

