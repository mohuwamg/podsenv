#!/usr/bin/env bash

set -e

# Define installation directory
PODSENV_ROOT="$HOME/.podsenv"
BIN_DIR="$PODSENV_ROOT/bin"

echo "Installing podsenv..."

# Create necessary directories
mkdir -p "$PODSENV_ROOT/versions"
mkdir -p "$PODSENV_ROOT/shims"
mkdir -p "$BIN_DIR"
mkdir -p "$PODSENV_ROOT/default_gem_home"

# Copy the podsenv script and supporting files
cp ./bin/podsenv "$BIN_DIR/podsenv"
chmod +x "$BIN_DIR/podsenv"

# Copy lib and libexec directories
cp -r ./lib "$PODSENV_ROOT/"
cp -r ./libexec "$PODSENV_ROOT/"

echo "podsenv installed to $BIN_DIR"

printf "\nNow, add the following lines to your shell configuration file (e.g., ~/.bashrc, ~/.zshrc):\n"
printf "\n# podsenv configuration\n"
printf "export PATH=\"%s:%s/shims:\$PATH\"\n" "$BIN_DIR" "$PODSENV_ROOT"
printf "eval \"\$(podsenv init -)\"\n"
printf "\nAfter adding, run \"source ~/.bashrc\" (or your shell config file) to apply the changes.\n"

# Run rehash to ensure shims are generated (even if no versions are installed yet)
"$BIN_DIR/podsenv" rehash

echo "Installation complete!"


