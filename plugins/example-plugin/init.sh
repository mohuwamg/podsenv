#!/usr/bin/env bash
# Example podsenv plugin
# This is a demonstration plugin showing how to extend podsenv functionality

# Plugin metadata
PLUGIN_NAME="example-plugin"
PLUGIN_VERSION="1.0.0"
PLUGIN_DESCRIPTION="Example plugin demonstrating podsenv plugin system"

# Plugin initialization
echo "Loading example plugin v${PLUGIN_VERSION}"

# Add custom commands or functions here
example_plugin_info() {
    echo "Example Plugin Information:"
    echo "  Name: $PLUGIN_NAME"
    echo "  Version: $PLUGIN_VERSION"
    echo "  Description: $PLUGIN_DESCRIPTION"
}

# Export functions that should be available globally
export -f example_plugin_info

# Plugin-specific configuration
EXAMPLE_PLUGIN_CONFIG_DIR="${PODSENV_ROOT}/plugins/${PLUGIN_NAME}/config"
mkdir -p "$EXAMPLE_PLUGIN_CONFIG_DIR"

# Log plugin loading
if [[ "${PODSENV_DEBUG:-}" == "1" ]]; then
    echo "[DEBUG] Example plugin loaded successfully"
fi