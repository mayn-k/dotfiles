# dotfiles

Portable dev environment for embedded/systems work.
**One command on a fresh Linux machine sets up everything.**

```
git clone <this-repo> ~/dotfiles
cd ~/dotfiles && ./bootstrap.sh
```

After it finishes: log out and back in. You now have zsh + tmux + neovim
configured exactly like the source machine, plus the `embed` workflow for
bare-metal + FreeRTOS projects.

## What's in here

```
dotfiles/
├── bootstrap.sh               ← new-machine installer (apt-based distros)
├── README.md
├── bash/.bashrc               ← stowed to ~/.bashrc
├── zsh/.zshrc                 ← stowed to ~/.zshrc
├── tmux/.tmux.conf            ← stowed to ~/.tmux.conf
├── nvim/.config/nvim/         ← stowed to ~/.config/nvim/
│   ├── init.lua
│   └── lua/
│       ├── embed.lua
│       ├── vim-options.lua
│       ├── plugins.lua
│       └── plugins/           (lazy.nvim auto-loads these)
│           ├── mason.lua        ← LSP installer
│           ├── lspconfig.lua    ← clangd tuned for arm-none-eabi
│           ├── cmp.lua          ← autocompletion
│           ├── telescope.lua
│           ├── treesitter.lua
│           └── ... (and your other existing plugins)
└── scripts/.local/bin/
    └── tmux-sessionizer       ← stowed to ~/.local/bin/
```

## How it works

**GNU Stow** is a symlink manager. Each top-level directory (`bash/`, `zsh/`,
`tmux/`, `nvim/`, `scripts/`) is a "package" whose contents mirror where they
should appear under `$HOME`. Running `stow bash` from the repo root creates
`~/.bashrc` as a symlink back to `bash/.bashrc` in this repo.

Edit the repo → changes appear live in `$HOME`. Push to git → pull on any
other machine → same setup, zero copy-paste.

## The embed workflow

The embed-workflow tooling (for embedded projects on STM32 etc.) lives in a
**separate** repo so you can iterate on it independently. `bootstrap.sh`
clones it to `~/work/embedded_systems/embed-workflow` and wires it in.

Before running `bootstrap.sh`, edit the `EMBED_REPO_URL` variable inside it to
point at your embed-workflow repo on GitHub. Or just set the env var:

```sh
EMBED_REPO_URL=git@github.com:youruser/embed-workflow.git ./bootstrap.sh
```

If you already have the embed-workflow files locally at
`~/work/embedded_systems/embed-workflow/`, bootstrap will skip the clone and
use what's there.

## Adding a new machine

1. Install `git`.
2. `git clone <this-repo> ~/dotfiles`
3. `cd ~/dotfiles && ./bootstrap.sh`
4. Log out and back in (for zsh + dialout).
5. Inside tmux, press `prefix + I` to install tmux plugins.
6. Inside nvim, `:Lazy sync` then `:Mason` and install `clangd`.

Works on: Pop!_OS, Ubuntu, Debian, Raspbian. Adapt the `PACKAGES` list in
`bootstrap.sh` for Fedora/Arch (different package names, different commands).

## Making changes

```sh
cd ~/dotfiles
$EDITOR zsh/.zshrc                # edit in the repo
# Your live ~/.zshrc already points at this file via symlink — change is instant
git commit -am "tweak zshrc"
git push                           # now other machines can pull
```

## Rolling back

If something breaks after stow:

```sh
cd ~/dotfiles
stow -D bash zsh tmux nvim scripts    # remove all the symlinks
# your old config files are in ~/.dotfiles-backup-<timestamp>/ from the first run
```

## Per-machine overrides

For anything specific to one machine (API keys, paths that vary, laptop-only
settings), use these files — they are loaded if present but not tracked by git:

- `~/.zshrc.local`
- `~/.bashrc.local`

The dotfiles `.zshrc` and `.bashrc` source them at the end.

## Diagnosing problems

Run `embed-doctor` anytime. It checks PATH, commands, tmux bindings, tools,
udev permissions, and whether the board is plugged in.
