#!/usr/bin/env bash
start_dir="~/code/$(ls -d -l ~/code/* | sed "s@^.*/@@" | fzf)"
session_name=$(basename "$start_dir")
if ! tmux has-session -t "$session_name" 2>/dev/null; then
	tmux new -s "$session_name" -c "$start_dir" -d
fi
tmux switch-client -t "$session_name"
