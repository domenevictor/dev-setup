# dev-setup

My portable dev environment: fish, tmux, Neovim, git and language runtimes.
Works on macOS and on Ubuntu/Debian (x86_64 or arm64). It knows nothing about
any particular machine; server-specific setup lives in `agent-server-setup`.

## Install

```bash
git clone git@github.com:domenevictor/dev-setup.git ~/code/dev-setup
~/code/dev-setup/install.sh
```

Options: `--link-only` (just relink configs), `--no-runtimes` (skip mise),
`--no-chsh` (keep the current login shell), `--no-desktop` (skip desktop apps).
Re-running is safe.

Desktop apps (`Brewfile.desktop`: Ghostty) are installed only on a physical
Mac. VMs and Linux machines skip them automatically. An app you already
installed by hand is left alone.

What it does:

1. Prerequisites: Xcode Command Line Tools on macOS; `linux/apt-packages.txt` on Linux.
2. Homebrew (on Linux too) and everything in `Brewfile`.
3. Symlinks every file in `home/` to the same place under `~`. Anything already
   there is moved to `~/.dev-setup-backup/<date>/` first.
4. Sources `~/.config/dev-setup/env.sh` from `.zshenv`, `.bashrc` and `.profile`,
   so bash/zsh (which Claude Code and Codex use for commands) get the same PATH as fish.
5. Adds the tmux agent-status hooks to Claude Code and Codex (merges; keeps your other hooks).
6. Installs runtimes with mise, tmux plugins, Neovim plugins, parsers and language servers.
7. Makes fish the login shell.

Your git name and email are not in this repo. Set them once per machine:

```bash
git config --global user.name "Your Name"
```

## Update

```bash
cd ~/code/dev-setup && git pull && ./install.sh
```

In Neovim, `:Lazy update` updates plugins; commit the changed `lazy-lock.json`.

Configs are linked file by file, so after **adding or deleting** a file under
`home/`, run `./install.sh --link-only` (it also removes links to deleted files).
Editing an existing file takes effect right away.

## Themes

Default: **rose-pine-main** (Ghostty: Rose Pine). Also installed:
**rose-pine-moon** (Rose Pine Moon), **tokyonight-night** (TokyoNight Night),
**tokyonight-moon** (TokyoNight Moon) and **gruvbox-material** (Gruvbox
Material Dark).

- Neovim: `,fc` switches with live preview (for that session). To change the
  default, edit `home/.config/nvim/lua/plugins/ui.lua`.
- Ghostty: uncomment the matching line in `home/.config/ghostty/config`, then
  Cmd+Shift+, to reload.
- tmux uses the terminal's own colors, so it follows Ghostty automatically.

## What's where

| Path | What |
| --- | --- |
| `Brewfile` | CLI tools (both OSes) |
| `Brewfile.desktop` | desktop apps for a physical Mac (Ghostty) |
| `linux/apt-packages.txt` | Linux-only system packages (compilers, clangd) |
| `home/.config/fish/config.fish` | shell: PATH, abbreviations, tool init |
| `home/.config/starship.toml` | prompt (`➜ [host] dir git:(branch) ✗`) |
| `home/.config/tmux/tmux.conf` | tmux: keys, status bar with agent state, resurrect/continuum |
| `home/.config/nvim/` | Neovim (Lua, lazy.nvim) |
| `home/.config/mise/config.toml` | runtimes: node, pnpm, bun, python, uv, rust |
| `home/.config/git/` | shared git settings and global ignore |
| `home/.config/ghostty/config` | terminal (laptop only) |
| `home/.local/bin/tmux-agent-status` | marks a tmux window ● working / ! waiting / ✓ done |
| `agents/claude-hooks.json` | Claude Code hooks merged into `~/.claude/settings.json` |

## Cheat sheet

**tmux** (prefix `C-b`)

| Keys | Action |
| --- | --- |
| `C-h/j/k/l` | move between panes *and* nvim splits |
| `prefix \|` / `prefix -` | split side by side / stacked (same folder) |
| `prefix Tab` | last window |
| `prefix H/J/K/L` | resize |
| `prefix C-l` | clear screen |
| `prefix w` | all sessions and windows, with agent state |
| `prefix C-s` / `C-r` | save / restore sessions (also automatic every 10 min) |
| `prefix r` | reload config |

The status bar marks windows running an agent: `●` working, `!` waiting for you, `✓` done.

**Neovim** (leader `,`; press it and wait to see everything)

| Keys | Action |
| --- | --- |
| `C-p`, `,ff` | find files |
| `,/`, `,fg` | grep |
| `,fb` `,fr` `,fs` | buffers, recent files, symbols |
| `,C` / `,fd` | diagnostics in this file / everywhere |
| `,\|` / `,-` | split right / below (same keys as tmux) |
| `,H` `,J` `,K` `,L` | move this split to the far left / bottom / top / right |
| `,z` | zoom this split (toggle) |
| `,x` / `,o` | close this split / close all others |
| `,=` / `,r` | equalize sizes / rotate splits |
| `,e` | file tree on the left (also opens for `nvim .`) |
| `-` | this folder as an editable buffer (rename/move/delete by editing text) |
| `gd`, `grr`, `gri`, `K` | definition, references, implementation, hover |
| `C-w d` | diagnostics for this line |
| `grn`, `gra` | rename, code action |
| `,k` | format (also on save; `:FormatToggle` to turn off) |
| `,w` | strip trailing whitespace |
| `gc` | comment |
| `sa` `sd` `sr` | add / delete / replace surroundings |
| `ga` | align (e.g. `gaip=`) |
| `]h` `[h` `,hs` `,hr` `,hp` `,hb` | git hunks: next, prev, stage, reset, preview, blame |
| `,lg` | lazygit |
| `,ac` `,as` `,ab` | Claude Code: toggle, send selection, add file |
| `,aa` `,ad` | accept / reject Claude's proposed diff |
| `jk` | leave insert mode |

Completion: `C-n`/`C-p` move, `C-y` accepts, `C-e` closes.

**fish**: `z <dir>` jumps to a frequent folder, `C-r` searches history,
`C-t` finds a file. Abbreviations: `g gs gd ga gc gco gp gl glo lg v t cc cx`.

## Linux notes

- Homebrew runs on Linux too, so the same `Brewfile` works. C/C++ compilers and
  `clangd` come from apt.
- The first run asks for your password for apt and to change the shell.
- Claude Code and Codex are installed from Homebrew casks on macOS only. On
  Linux, install them by hand for now: `curl -fsSL https://claude.ai/install.sh | bash`
  and `npm install -g @openai/codex`.
- Not yet tested on a real Linux machine; the Raspberry Pi 5 is the first target.
