#!/usr/bin/env bash
#
# bootstrap.sh — set up a fresh Linux machine with the full dev environment.
#
# Usage:
#   git clone <this-repo-url> ~/dotfiles
#   cd ~/dotfiles && ./bootstrap.sh
#
# What it does:
#   1. Installs system packages (apt-based distros: Pop!_OS, Ubuntu, Debian, Raspbian)
#   2. Installs oh-my-zsh + plugins
#   3. Installs tpm (tmux plugin manager)
#   4. Clones the embed-workflow repo (or pulls if it exists)
#   5. Runs `stow` to symlink all dotfiles into $HOME
#   6. Runs embed-workflow/install.sh
#   7. Prints next-step instructions
#
# Safe to re-run. Idempotent.

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────────────────
C_GRN=$'\e[32m'; C_YLW=$'\e[33m'; C_RED=$'\e[31m'; C_BLU=$'\e[34m'; C_RST=$'\e[0m'
say()  { printf '\n%s▸ %s%s\n' "$C_BLU" "$*" "$C_RST"; }
ok()   { printf '%s✓%s %s\n' "$C_GRN" "$C_RST" "$*"; }
warn() { printf '%s!%s %s\n' "$C_YLW" "$C_RST" "$*"; }
die()  { printf '%s✗ %s%s\n' "$C_RED" "$*" "$C_RST" >&2; exit 1; }

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
EMBED_PARENT="$HOME/work/embedded_systems"
EMBED_DIR="$EMBED_PARENT/embed-workflow"
EMBED_REPO_URL="${EMBED_REPO_URL:-git@github.com:mayn_k/embed-workflow.git}"

say "Dotfiles bootstrap — from $DOTFILES_DIR"

# ─── 1. Detect distro ────────────────────────────────────────────────────────
if ! command -v apt-get >/dev/null 2>&1; then
    die "This bootstrap supports apt-based distros (Ubuntu/Debian/Pop!_OS/Raspbian). On other distros, adapt the package-install step."
fi

if [[ $EUID -eq 0 ]]; then
    die "Do not run as root. The script will sudo when needed."
fi

# ─── 2. Install system packages ──────────────────────────────────────────────
say "Installing system packages (sudo required)"
PACKAGES=(
    # Core
    git curl wget unzip build-essential
    # Shell / tmux / editor
    zsh tmux neovim
    # CLI tools we rely on
    fzf bat ripgrep
    # Dotfiles manager
    stow
    # Embedded toolchain
    gcc-arm-none-eabi libnewlib-arm-none-eabi gdb-multiarch
    # Flashers / debuggers
    openocd stlink-tools
    # Serial monitor
    tio
    # Build intel
    bear
    # clang-format for the embed workflow save-format
    clang-format
    # For some nvim plugins
    python3-pip
)

sudo apt-get update
sudo apt-get install -y "${PACKAGES[@]}"
ok "System packages installed"

# Symlink gdb-multiarch as arm-none-eabi-gdb if it's missing
if ! command -v arm-none-eabi-gdb >/dev/null 2>&1 && command -v gdb-multiarch >/dev/null 2>&1; then
    say "Symlinking gdb-multiarch → arm-none-eabi-gdb"
    sudo ln -sf "$(command -v gdb-multiarch)" /usr/local/bin/arm-none-eabi-gdb
    ok "arm-none-eabi-gdb available"
fi

# Add user to dialout for serial access without sudo
if ! groups | grep -qw dialout; then
    say "Adding $USER to 'dialout' group (for /dev/ttyACM* without sudo)"
    sudo usermod -aG dialout "$USER"
    warn "You must LOG OUT and back in for dialout group to take effect."
fi

# ─── 3. oh-my-zsh ────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    say "Installing oh-my-zsh"
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ok "oh-my-zsh installed"
else
    ok "oh-my-zsh already present"
fi

# zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for plugin_pair in \
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions" \
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting"
do
    name="${plugin_pair%%|*}"; url="${plugin_pair##*|}"
    target="$ZSH_CUSTOM/plugins/$name"
    if [[ ! -d "$target" ]]; then
        say "Installing zsh plugin: $name"
        git clone --depth 1 "$url" "$target"
        ok "$name installed"
    fi
done

# pixegami-agnoster theme
PIXEGAMI_THEME="$ZSH_CUSTOM/themes/pixegami-agnoster.zsh-theme"
if [[ ! -f "$PIXEGAMI_THEME" ]]; then
    say "Fetching pixegami-agnoster theme"
    mkdir -p "$(dirname "$PIXEGAMI_THEME")"
    curl -fsSL -o "$PIXEGAMI_THEME" \
        "https://raw.githubusercontent.com/pixegami/pixegami-agnoster-theme/main/pixegami-agnoster.zsh-theme" \
        || warn "Theme download failed — the zshrc will fall back to default theme on next login"
fi

# ─── 4. tpm (tmux plugin manager) ────────────────────────────────────────────
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
    say "Installing tmux plugin manager (tpm)"
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
    ok "tpm installed"
fi

# ─── 5. Clone / update embed-workflow ────────────────────────────────────────
say "Setting up embed-workflow"
mkdir -p "$EMBED_PARENT"
if [[ -d "$EMBED_DIR/.git" ]]; then
    ( cd "$EMBED_DIR" && git pull --ff-only ) && ok "embed-workflow updated"
elif [[ -d "$EMBED_DIR" ]]; then
    warn "$EMBED_DIR exists but isn't a git repo. Leaving as-is."
elif [[ "$EMBED_REPO_URL" == *CHANGE_ME* ]]; then
    warn "EMBED_REPO_URL not set — skipping clone of embed-workflow."
    warn "Either set it in bootstrap.sh or put the embed-workflow files at $EMBED_DIR manually."
else
    git clone --depth 1 "$EMBED_REPO_URL" "$EMBED_DIR"
    ok "embed-workflow cloned to $EMBED_DIR"
fi

# ─── 6. Stow dotfiles ────────────────────────────────────────────────────────
say "Linking dotfiles with stow"
cd "$DOTFILES_DIR"

# Back up files that would conflict (stow refuses to clobber)
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
CONFLICTS=()
check_conflict() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        CONFLICTS+=("$target")
    fi
}
check_conflict "$HOME/.bashrc"
check_conflict "$HOME/.zshrc"
check_conflict "$HOME/.tmux.conf"
check_conflict "$HOME/.config/nvim/init.lua"

if [[ ${#CONFLICTS[@]} -gt 0 ]]; then
    warn "Conflicting files found. Backing up to $BACKUP_DIR:"
    mkdir -p "$BACKUP_DIR"
    for f in "${CONFLICTS[@]}"; do
        warn "  $f → $BACKUP_DIR/"
        mv "$f" "$BACKUP_DIR/"
    done
fi

# Create ~/.config dir so stow can link into it
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.local/bin"

# Stow each package (idempotent — re-running is safe)
for pkg in bash zsh tmux nvim scripts; do
    if [[ -d "$pkg" ]]; then
        stow --target="$HOME" --restow "$pkg"
        ok "stow: $pkg"
    fi
done

# ─── 7. Run embed-workflow installer ─────────────────────────────────────────
if [[ -x "$EMBED_DIR/install.sh" ]]; then
    say "Running embed-workflow install.sh"
    "$EMBED_DIR/install.sh" || warn "embed-workflow install.sh reported issues — review above"
fi

# ─── 8. Done ─────────────────────────────────────────────────────────────────
say "Bootstrap complete"
cat <<EOF

${C_GRN}Next steps:${C_RST}

1. Change your shell to zsh (if not already):
     chsh -s \$(which zsh)
   Then log out and back in.

2. Install tmux plugins: open tmux, then press ${C_BLU}prefix + I${C_RST} (capital i).

3. Install nvim plugins: open nvim. lazy.nvim bootstraps itself and runs :Lazy sync
   on first open. Then inside nvim run ${C_BLU}:Mason${C_RST} and install ${C_BLU}clangd${C_RST}.

4. Verify the embed workflow:
     ${C_BLU}embed-doctor${C_RST}
     ${C_BLU}embed list boards${C_RST}
     ${C_BLU}embed new blink nucleo-l476rg${C_RST}

5. If you were added to 'dialout' just now, ${C_YLW}log out and back in${C_RST} for
   /dev/ttyACM* to work without sudo.

${C_BLU}If anything is wrong, run:  embed-doctor${C_RST}

EOF
