#!/usr/bin/env bash

sessions="$(tmux list-sessions -F '#S')"
current_session="$(tmux display-message -p '#S')"

# We use --print-query and --expect=enter to capture:
#   - The key the user pressed to trigger acceptance (enter)
#   - The final line typed or selected by the user
selected="$(
  echo "${sessions}" \
    | grep -v "^${current_session}$" \
    | fzf --reverse --prompt="Switch or create session> " \
      --print-query 
)"

session_name="$(echo "$selected" | tail -n 1)"

# if 1, then we have a new session
is_new_session=$(echo "$selected" | wc -l)

# If user hit ESC or there was no name typed, do nothing
if [ -z "$session_name" ]; then
  exit 0
fi

# Check if the session already exists
# if echo "$SESSIONS" | grep -qx "$SESSION_NAME"; then
if [ "$is_new_session" -eq 1 ]; then
  # Create a new session in detached mode, then switch to it
  tmux new-session -ds "$session_name" -c "$HOME"
fi
tmux switch-client -t "$session_name"

