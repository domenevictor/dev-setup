# ---------------------------------------------------------------- environment
# Runs for every fish, including non-interactive ones (ssh commands such as
# `mosh-server`, which therefore gets found on PATH).
for brew in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew
    if test -x $brew
        $brew shellenv fish | source
        break
    end
end
fish_add_path -g ~/.local/bin

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx MANPAGER "nvim +Man!"
set -q LANG; or set -gx LANG en_US.UTF-8 # mosh needs a UTF-8 locale

# ------------------------------------------------------- non-interactive only
if not status is-interactive
    fish_add_path -g ~/.local/share/mise/shims
    return
end

# ---------------------------------------------------------- interactive only
set -g fish_greeting

type -q mise; and mise activate fish | source
type -q starship; and starship init fish | source
type -q zoxide; and zoxide init fish | source
if type -q fzf
    fzf --fish | source
    set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --exclude .git"
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    set -gx FZF_DEFAULT_OPTS "--height 40% --layout reverse --border"
end

# Abbreviations expand when you press space, so history shows the real command.
abbr -a v nvim
abbr -a vim nvim
abbr -a g git
abbr -a gs git status -sb
abbr -a gd git diff
abbr -a gds git diff --staged
abbr -a ga git add
abbr -a gc git commit
abbr -a gco git switch
abbr -a gp git push
abbr -a gl git pull
abbr -a glo git log --oneline --graph -20
abbr -a lg lazygit
abbr -a t tmux new -A -s main
abbr -a cc claude
abbr -a cx codex

if type -q eza
    alias ls "eza --group-directories-first"
    alias ll "eza -la --git --group-directories-first"
    alias tree "eza --tree --git-ignore"
end
