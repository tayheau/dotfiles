#!/usr/bin/env bash
for f in .bash_profile .gitconfig; do
	ln -s "${PWD}/${f}" "${HOME}"
done

[[ command -v nvim  >/dev/null 2>&1 ]] && echo "lol"
