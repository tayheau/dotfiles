#!/usr/bin/env bash
start_dir="$HOME/code/$(find -L ~/code -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | fzf)"
session_name=$(basename "$start_dir")
if ! tmux has-session -t "$session_name" 2>/dev/null; then
	tmux new -s "$session_name" -c "$start_dir" -d
	cd "$start_dir"
fi
tmux switch-client -t "$session_name"
