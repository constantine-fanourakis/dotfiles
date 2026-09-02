export SHELL=/bin/zsh

# Disable virtualenv's default prompt modification (starship handles the prompt)
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Warn (not fail) when an expected tool/file is missing, so a machine
# missing something optional stays usable instead of erroring on startup.
_zshrc_warn() { print -u2 -- "zshrc: $1"; }

case "$OSTYPE" in
  darwin*) IS_MACOS=1 ;;
  linux*)  IS_LINUX=1 ;;
esac

# ============================== macOS-only ==============================
if [[ -n "$IS_MACOS" ]]; then
  # Homebrew (Apple Silicon or Intel prefix)
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    _zshrc_warn "homebrew not found, skipping brew shellenv/python paths"
  fi

  # 1Password SSH agent
  export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

  # user-local python
  export PATH="$HOME/Library/Python/3.9/bin:$PATH"
  if command -v brew >/dev/null; then
    export PATH="$(brew --prefix)/opt/python@3/libexec/bin:$PATH"
  fi

  # >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  CONDA_BASE=""
  for _candidate in "/opt/homebrew/Caskroom/miniconda/base" "$HOME/miniconda3" "/opt/miniconda3" "/opt/conda"; do
    if [[ -x "$_candidate/bin/conda" ]]; then
      CONDA_BASE="$_candidate"
      break
    fi
  done
  if [[ -n "$CONDA_BASE" ]]; then
    __conda_setup="$("$CONDA_BASE/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    elif [ -f "$CONDA_BASE/etc/profile.d/conda.sh" ]; then
        . "$CONDA_BASE/etc/profile.d/conda.sh"
    else
        export PATH="$CONDA_BASE/bin:$PATH"
    fi
    unset __conda_setup
  else
    _zshrc_warn "conda not found, skipping conda initialize"
  fi
  unset _candidate CONDA_BASE
  # <<< conda initialize <<<

  # Docker Desktop CLI completions
  if [[ -d "$HOME/.docker/completions" ]]; then
    fpath=("$HOME/.docker/completions" $fpath)
  else
    _zshrc_warn "~/.docker/completions not found, skipping docker completions"
  fi

  # fnm node version manager
  if command -v fnm >/dev/null; then
    eval "$(fnm env --use-on-cd)"
  else
    _zshrc_warn "fnm not found, skipping node version manager init"
  fi
fi
# ============================ end macOS-only =============================

# user-local binaries (uv, uvx, claude, qmk)
export PATH="$HOME/.local/bin:$PATH"

# Aliases
alias vim="nvim"
alias ll="ls -l"
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Catch ~/.gitconfig silently losing its include of the shared dotfiles
# config (e.g. `git config --global user.x` recreating the file from
# scratch, wiping the [include] block).
if [[ -f "$HOME/.gitconfig.global" ]] && ! git config --get alias.sweep >/dev/null 2>&1; then
  _zshrc_warn "~/.gitconfig does not include ~/.gitconfig.global — shared git config (aliases, excludesfile, lfs, rerere) is inactive. Add:\n[include]\n\tpath = ~/.gitconfig.global"
fi

# bindkey '\e[H' beginning-of-line
# bindkey '\e[F' end-of-line

# fix title
DISABLE_AUTO_TITLE="true"
function stitle() { echo -en "\e]2;$@\a" }

if command -v nvim >/dev/null; then
  export EDITOR="$(command -v nvim)"
else
  _zshrc_warn "nvim not found, falling back to vim for \$EDITOR"
  export EDITOR="$(command -v vim)"
fi

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

autoload -Uz compinit
compinit

# zsh-vi-mode plugin
ZSH_PLUGINS="${HOME}/.zsh/plugins"
ZVM_DIR="${ZSH_PLUGINS}/zsh-vi-mode"
if [[ -f "$ZVM_DIR/zsh-vi-mode.plugin.zsh" ]]; then
  ZVM_INIT_MODE=sourcing # Do the initialization when the script is sourced
  source "$ZVM_DIR/zsh-vi-mode.plugin.zsh"
else
  _zshrc_warn "zsh-vi-mode plugin not found at $ZVM_DIR, skipping"
fi

# Set up fzf key bindings and fuzzy completion
if command -v fzf >/dev/null; then
  source <(fzf --zsh)
else
  _zshrc_warn "fzf not found, skipping key bindings/completion"
fi

if command -v starship >/dev/null; then
  eval "$(starship init zsh)"
else
  _zshrc_warn "starship not found, skipping prompt init"
fi

export _ZO_DOCTOR=0
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd="z"
else
  _zshrc_warn "zoxide not found, skipping (cd stays the builtin)"
fi
