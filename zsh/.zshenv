# Keep non-interactive shells lightweight. Interactive setup is in .zshrc.
typeset -U path PATH
path=("$HOME/.local/bin" $path)
