# Shared environment for bash and zsh (fish has its own in config.fish).
# Sourced from ~/.zshenv, ~/.bashrc and ~/.profile, so non-interactive shells
# (Claude Code, Codex, scripts, ssh commands) see Homebrew and mise tools too.
for _b in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
  if [ -x "$_b" ]; then eval "$("$_b" shellenv)"; break; fi
done
unset _b

case ":$PATH:" in *":$HOME/.local/share/mise/shims:"*) ;; *) PATH="$HOME/.local/share/mise/shims:$PATH" ;; esac
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac
export PATH

export EDITOR=nvim VISUAL=nvim
export LANG="${LANG:-en_US.UTF-8}" # mosh-server refuses to start without a UTF-8 locale
