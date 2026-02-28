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
  
  # defaults
  local session_name=$(basename "$PWD")
  local extended_apps=()
  
  # parse options
  while getopts ":s:e:" opt; do
    case $opt in
      s)
        session_name="$OPTARG"
        ;;
      e)
        extended_apps+=("$OPTARG")
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        return 1
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        return 1
        ;;
    esac
  done

  if tmux has-session -t "$session_name" &> /dev/null; then
    echo "A session with this name already exists. Try another name." >&2
    return 1
  fi

  # start the tmux session and the first window with nvim
  tmux new-session -d -s "$session_name" -n "nvim"
  tmux send-keys nvim C-m

  # ceate additional windows for opencode and a shell session
  tmux new-window -n "opencode"
  tmux send-keys opencode C-m

  tmux new-window -n "shell"

  # create windows for any additional apps
  for app in "${extended_apps[@]}"; do
    tmux new-window -n "$app"
    tmux send-keys "$app" C-m
  done
  
  # select the active window as nvim and attach to the session
  tmux select-window -t "nvim"
  tmux attach-session -t "$session_name"
}

