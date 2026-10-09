#!/usr/bin/env bash

# If an argument is provided, use it directly as the directory.
# Default value for the flag (no nvim opened)
open_nvim="false"
use_tmuxinator="false"
if [[ $# -gt 0 ]]; then
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --open-nvim)
                open_nvim="true"
                shift
                ;;
            --tmuxinator)
                use_tmuxinator="true"
                shift
                ;;
            *)
                # If an argument doesn't match a flag, treat it as the directory
                selected="$1"
                shift
                ;;
        esac
    done
else
    # 1) Use zoxide's interactive selector first.
    #    Pressing ESC or Ctrl-C in zoxide leaves 'selected' empty.
    selected="$(zoxide query --interactive 2>/dev/null)"

    # 2) If zoxide was cancelled or gave no result, fall back to fd + fzf.
    if [[ -z "$selected" ]]; then
        # Adjust the directories you want to search below as needed.
        # fd is faster than find, and we can pipe it into fzf for selection.
        selected="$(
            fd --type d . \
               ~/Projects \
            | fzf
        )"
    fi
fi

# If there's still no selection, exit with no action.
if [[ -z "$selected" ]]; then
    exit 0
fi

# Check if tmuxinator config exists for the selected project
tmuxinator_config=~/.config/tmuxinator/"$selected.yml"

# Use tmuxinator if available
if [[ "$use_tmuxinator" == "true" && -f "$tmuxinator_config" ]]; then
    tmuxinator start "$selected"
    exit 0
fi

# Combine parent directory and basename to form a unique tmux session name.
parent_dir=$(dirname "$selected")
selected_name="$(basename "$parent_dir")_$(basename "$selected")"

# Check if tmux is running at all.
tmux_running="$(pgrep tmux)"

# 1) If we're **not** inside tmux and tmux is not running at all,
#    just start a new tmux session and attach to it.
if [[ -z "$TMUX" && -z "$tmux_running" ]]; then
    tmux new-session -s "$selected_name" -c "$selected"

    # If open_nvim is true, open nvim in the new session
    if [[ "$open_nvim" == "true" ]]; then
        tmux send-keys 'nvim .' C-m
    fi
    exit 0
fi

# 2) If the session does not already exist, create it (detached) in that directory.
if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"

    # If open_nvim is true, open nvim in the new session
    if [[ "$open_nvim" == "true" ]]; then
        tmux send-keys 'nvim .' C-m
    fi
fi

# 3) Switch to the session (whether newly created or already existing).
tmux switch-client -t "$selected_name"
