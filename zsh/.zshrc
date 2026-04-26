# ~/.zshrc
# Managed by dotfiles repo. Edit the repo version, then: stow -R zsh

# ─── Oh-my-zsh ───────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="pixegami-agnoster"

plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)

# Guard — avoid hard-failing on a fresh machine where oh-my-zsh isn't installed yet.
# The bootstrap script installs it. If it's missing, you just get a plain zsh.
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# ─── PATH ────────────────────────────────────────────────────────────────────
# Put ~/.local/bin first so `embed`, `embed-popup-*`, personal scripts win.
export PATH="$HOME/.local/bin:$PATH"

# STM32CubeProgrammer (optional — keeps your existing setup working)
[[ -d "$HOME/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin" ]] && \
    export STM32_PRG_PATH="$HOME/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin" && \
    export PATH="$STM32_PRG_PATH:$PATH"

# ─── fzf ─────────────────────────────────────────────────────────────────────
# Ctrl-P: fuzzy-find files in current dir with batcat preview (your binding)
if command -v fzf >/dev/null 2>&1; then
    if command -v batcat >/dev/null 2>&1; then
        bindkey -s '^P' 'fzf --preview "batcat --style=numbers --color=always {}"\n'
    else
        bindkey -s '^P' 'fzf\n'
    fi
fi

# Ctrl-F: tmux sessionizer
[[ -x "$HOME/.local/bin/tmux-sessionizer" ]] && \
    bindkey -s '^f' '~/.local/bin/tmux-sessionizer\n'

# ─── Aliases ─────────────────────────────────────────────────────────────────
# Existing
alias cf="~/work/cp/scripts/new_contest.sh codeforces"
alias abc="~/work/cp/scripts/new_contest.sh atcoder"
alias practice="~/work/cp/scripts/new_practice.sh"
alias sp="~/.local/bin/tmux-sessionizer"
alias stm32="~/work/embedded_systems/stm/scripts/new_stm32_project.sh"

# New — embed workflow shortcuts
alias en="embed new"
alias eo="embed open"
alias el="embed list"
alias ef="embed flash"
alias ed="embed-doctor"

# Quality of life
alias ll='ls -alFh --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'

# ─── Per-machine overrides ───────────────────────────────────────────────────
# Not tracked in git — for things specific to this laptop/server.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
