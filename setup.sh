#!/usr/bin/env bash
# for f in .bash_profile .gitconfig; do
# 	ln -s "${PWD}/${f}" "${HOME}"
# done

# [[ command -v nvim  >/dev/null 2>&1 ]] && echo "lol"


mkdir -p "${TYPST_PACKAGE_PATH}/local/tayheau-slides/1.0.0"
ln -s "$(pwd)/tayheau_slides.typ" "${TYPST_PACKAGE_PATH}/local/tayheau-slides/1.0.0/lib.typ"
cat > "${TYPST_PACKAGE_PATH}/local/tayheau-slides/1.0.0/typst.toml" <<'EOF'
[package]
name = "tayheau-slides"
version = "1.0.0"
entrypoint = "lib.typ"
EOF
