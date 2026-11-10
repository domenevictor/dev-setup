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

# The prompt shows how long the last command took (if over 2s). Skip that for
# interactive programs: time spent in nvim or tmux isn't worth reporting.
function __hide_interactive_duration --on-event fish_postexec
    set -l cmd (string split -f1 ' ' -- (string trim -- $argv[1]))
    if contains -- $cmd nvim vim vi lazygit tmux ssh mosh claude codex less man btop htop top
        set -g CMD_DURATION 0
    end
end
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

# Plain `tmux` reattaches to the "main" session instead of creating a new
# numbered one every time (which tmux-resurrect then keeps bringing back).
# Any arguments go to tmux unchanged, e.g. `tmux new -s work`.
function tmux --wraps tmux --description "tmux; no args = attach or create 'main'"
    if test (count $argv) -eq 0
        command tmux new-session -A -s main
    else
        command tmux $argv
    end
end
abbr -a cc claude
abbr -a cx codex

# Codex normally runs its hooks in a shared background server that doesn't know
# which tmux pane you're in, so the status bar markers end up on the wrong pane.
# Inside tmux, run interactive Codex standalone (--no-daemon) so they work.
function codex --wraps codex --description "codex; standalone inside tmux"
    if not set -q TMUX
        command codex $argv
    else if test (count $argv) -eq 0; or string match -q -- '-*' $argv[1]
        command codex --no-daemon $argv
    else if contains -- $argv[1] resume fork agents
        command codex $argv[1] --no-daemon $argv[2..]
    else if contains -- $argv[1] exec e review login logout mcp plugin app-server remote-control app completion update doctor sandbox debug apply a queue archive delete unarchive migrate-rollouts migrate-nfs-db cloud exec-server features help
        command codex $argv
    else
        command codex --no-daemon $argv # a prompt: codex "fix the tests"
    end
end

if type -q eza
    alias ls "eza --group-directories-first"
    alias ll "eza -la --git --group-directories-first"
    alias tree "eza --tree --git-ignore"
end
