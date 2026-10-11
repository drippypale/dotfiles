# Keep non-interactive shells lightweight. Interactive setup is in .zshrc.
typeset -U path PATH
path=("$HOME/.local/bin" $path)

# A manual git-clone fzf install (~/.fzf/install) puts the binary here
# instead of on PATH. Belongs here, not .zshrc, so non-interactive shells
# (tmux popups, scripts run via `zsh -c`) can find it too.
[[ -d "$HOME/.fzf/bin" ]] && path=("$HOME/.fzf/bin" $path)
