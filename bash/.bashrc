# ~/.bashrc
# Managed by dotfiles. Edit the repo version, then: stow -R bash

# Interactive-only guard
case $- in *i*) ;; *) return;; esac

# History
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

# lesspipe
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Colored prompt
if [ -x /usr/bin/tput ] && tput setaf 1 >/dev/null 2>&1; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi

# PATH
export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin" ]] && \
    export STM32_PRG_PATH="$HOME/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin" && \
    export PATH="$STM32_PRG_PATH:$PATH"

# ls colors
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# QoL aliases (match zshrc)
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'

# embed shortcuts
alias en="embed new"
alias eo="embed open"
alias el="embed list"
alias ef="embed flash"
alias ed="embed-doctor"

# bash completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Per-machine overrides
[ -f "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"
