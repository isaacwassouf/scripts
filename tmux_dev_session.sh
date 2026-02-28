#!/usr/bin/env bash

for cmd in tmux opencode; do
  # check if tmux is installed.
  if ! command -v "$cmd" &> /dev/null; then
      echo "Dude, You're missing $cmd." >&2
      return 1
  fi
done

# tmux with frinds :)
twf() {
  if [[ -n "$TMUX" ]]; then
    echo "One tmux session at a time, please." >&2
    return 1
  fi

  local session_name="${1:-$(basename "$PWD")}"

  if tmux has-session -t "$session_name" &> /dev/null; then
    echo "A session with this name already exists. Try another name." >&2
    return 1
  fi

  tmux new-session -d -s "$session_name" -n "nvim"
  tmux send-keys nvim C-m

  tmux new-window -n "opencode"
  tmux send-keys opencode C-m

  tmux new-window -n "shell"

  tmux select-window -t "nvim"
}
