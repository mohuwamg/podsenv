#!/usr/bin/env bash
# Example plugin hook: after_install
# This hook is executed after a CocoaPods version is installed

# Hook parameters:
# $1 - installed version
# $2 - installation path

installed_version="$1"
installation_path="$2"

echo "[Example Plugin] CocoaPods $installed_version has been installed to $installation_path"

# Example: Create a welcome message for the newly installed version
welcome_file="$installation_path/.podsenv-welcome"
cat > "$welcome_file" << EOF
Welcome to CocoaPods $installed_version!

This version was installed by podsenv with the example plugin.
Installation date: $(date)

For help with CocoaPods, run: pod --help
For help with podsenv, run: podsenv help
EOF

echo "[Example Plugin] Created welcome file at $welcome_file"

# Example: Log installation to plugin's log file
log_file="${PODSENV_ROOT}/plugins/example-plugin/install.log"
echo "$(date): Installed CocoaPods $installed_version to $installation_path" >> "$log_file"