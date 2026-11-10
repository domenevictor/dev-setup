#!/usr/bin/env bash
# dev-setup installer for macOS and Ubuntu/Debian. Safe to re-run.
#
#   ./install.sh               everything
#   ./install.sh --link-only   only (re)link config files into $HOME
#   ./install.sh --no-runtimes skip mise runtimes (node, python, rust, ...)
#   ./install.sh --no-chsh     don't change the login shell to fish
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
LINK_ONLY=0 RUNTIMES=1 CHSH=1
for arg in "$@"; do
  case "$arg" in
    --link-only) LINK_ONLY=1 ;;
    --no-runtimes) RUNTIMES=0 ;;
    --no-chsh) CHSH=0 ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

# Tools installed during this run (mise runtimes such as node/npm, which Mason
# needs for several language servers) must be visible to later steps.
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"

step() { printf '\n\033[1;32m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }

# ---------------------------------------------------------------- prereqs ---
install_prereqs() {
  step "System prerequisites"
  if [ "$OS" = Darwin ]; then
    if ! xcode-select -p >/dev/null 2>&1; then
      xcode-select --install || true
      echo "Finish the Command Line Tools install, then re-run ./install.sh"
      exit 1
    fi
    echo "Command Line Tools: $(xcode-select -p)"
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    # shellcheck disable=SC2046 # one package per word, on purpose
    sudo apt-get install -y -qq $(grep -vE '^\s*(#|$)' "$REPO/linux/apt-packages.txt")
  else
    echo "Only macOS and apt-based Linux (Ubuntu/Debian) are supported." >&2
    exit 1
  fi
}

# --------------------------------------------------------------- homebrew ---
load_brew() {
  command -v brew >/dev/null 2>&1 && return 0
  for b in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$b" ]; then eval "$("$b" shellenv)"; return 0; fi
  done
  return 1
}

install_brew() {
  step "Homebrew packages"
  if ! load_brew; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    load_brew
  fi
  brew bundle --file="$REPO/Brewfile"
}

# ------------------------------------------------------------------ links ---
# Every file under home/ is symlinked to the same path under $HOME.
# Anything already there (that isn't our link) is moved to ~/.dev-setup-backup/.
BACKUP="$HOME/.dev-setup-backup/$(date +%Y%m%d-%H%M%S)"

backup() { # $1 = path relative to $HOME
  local dst="$HOME/$1"
  [ -e "$dst" ] || [ -L "$dst" ] || return 0
  mkdir -p "$BACKUP/$(dirname "$1")"
  mv "$dst" "$BACKUP/$1"
  echo "  backed up ~/$1"
}

link_home() {
  step "Linking config files"
  # Old locations that would shadow the new configs.
  backup .tmux.conf
  [ -L "$HOME/.config/fish/functions/fish_prompt.fish" ] || backup .config/fish/functions/fish_prompt.fish

  local rel src dst
  while IFS= read -r rel; do
    src="$REPO/home/$rel" dst="$HOME/$rel"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then continue; fi
    backup "$rel"
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "  linked ~/$rel"
  done < <(cd "$REPO/home" && find . -type f ! -name .DS_Store | sed 's|^\./||' | sort)

  # bash/zsh (used by Claude Code, Codex and scripts) get the same PATH as fish.
  local line='[ -f "$HOME/.config/dev-setup/env.sh" ] && . "$HOME/.config/dev-setup/env.sh"'
  for rc in .zshenv .bashrc .profile; do
    grep -qsF '.config/dev-setup/env.sh' "$HOME/$rc" || { printf '\n# dev-setup\n%s\n' "$line" >>"$HOME/$rc"; echo "  sourced env.sh from ~/$rc"; }
  done
}

# ------------------------------------------------------------ agent hooks ---
# tmux shows each window's agent state (● working, ! waiting, ✓ done).
agent_hooks() {
  step "Agent status hooks (Claude Code, Codex)"
  local settings="$HOME/.claude/settings.json" tmp
  mkdir -p "$HOME/.claude"
  [ -s "$settings" ] || echo '{}' >"$settings"
  tmp="$(mktemp)"
  jq --slurpfile ours "$REPO/agents/claude-hooks.json" '
    reduce ($ours[0].hooks | to_entries[]) as $e (.;
      .hooks[$e.key] = ((.hooks[$e.key] // []) as $cur
        | if ([$cur[].hooks[]?.command] | index($e.value[0].hooks[0].command)) != null
          then $cur else $cur + $e.value end))' "$settings" >"$tmp" && mv "$tmp" "$settings"
  echo "  merged hooks into ~/.claude/settings.json"

  local codex="$HOME/.codex/config.toml"
  mkdir -p "$HOME/.codex"; touch "$codex"
  if ! grep -qE '^\s*notify\s*=' "$codex"; then
    # Top-level keys must come before any [table], so prepend.
    tmp="$(mktemp)"
    { printf 'notify = ["%s/.local/bin/tmux-agent-status", "done"]\n' "$HOME"; cat "$codex"; } >"$tmp" && mv "$tmp" "$codex"
    echo "  added notify to ~/.codex/config.toml"
  fi
}

# --------------------------------------------------------------- runtimes ---
install_runtimes() {
  step "Language runtimes (mise)"
  mise install --yes
  mise reshim
  mise ls --current
}

# ------------------------------------------------------------- tmux / nvim ---
install_tmux_plugins() {
  step "tmux plugins"
  # Clone the @plugin entries from tmux.conf ourselves: tpm's installer can hang
  # on macOS waiting for the git credential helper.
  local dir="$HOME/.local/share/tmux/plugins" plugin
  mkdir -p "$dir"
  for plugin in $(sed -nE 's/^set -g @plugin "([^"]+)".*/\1/p' "$REPO/home/.config/tmux/tmux.conf"); do
    if [ -d "$dir/${plugin#*/}" ]; then
      git -C "$dir/${plugin#*/}" pull -q --ff-only || warn "could not update $plugin"
    else
      GIT_TERMINAL_PROMPT=0 git -c credential.helper= clone -q --depth 1 "https://github.com/$plugin" "$dir/${plugin#*/}"
    fi
    echo "  $plugin"
  done
}

install_nvim_plugins() {
  step "Neovim plugins, parsers, language servers"
  nvim --headless "+Lazy! restore" +qa
  nvim --headless -c "lua require('nvim-treesitter').install(require('config.treesitter').parsers):wait(600000)" -c qa
  nvim --headless -c "MasonToolsInstallSync" -c qa || warn "some Mason tools failed; run :Mason in nvim"
  echo
}

# ------------------------------------------------------------------ shell ---
set_login_shell() {
  local fish_path; fish_path="$(command -v fish)"
  [ "${SHELL:-}" = "$fish_path" ] && return 0
  step "Login shell -> $fish_path"
  grep -qxF "$fish_path" /etc/shells || echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$fish_path"
}

# ------------------------------------------------------------------- main ---
if [ "$LINK_ONLY" = 1 ]; then
  link_home
  exit 0
fi

install_prereqs
install_brew
link_home
agent_hooks
[ "$RUNTIMES" = 1 ] && install_runtimes
install_tmux_plugins
install_nvim_plugins
[ "$CHSH" = 1 ] && set_login_shell

[ -d "$BACKUP" ] && echo "Previous configs saved in $BACKUP"
step "Done. Open a new terminal (or run: exec fish)."
