#!/usr/bin/env bash
# podsenv plugin system
# Provides functionality for loading and managing plugins

# Plugin system configuration
PODSENV_PLUGIN_DIR="${PODSENV_ROOT}/plugins"
PODSENV_PLUGIN_HOOKS_DIR="${PODSENV_ROOT}/share/podsenv/hooks"

# Available plugin hooks
PODSENV_HOOKS=(
    "before_install"
    "after_install"
    "before_uninstall"
    "after_uninstall"
    "before_version_change"
    "after_version_change"
    "before_rehash"
    "after_rehash"
)

# Load all enabled plugins
podsenv_load_plugins() {
    local plugin_dir="$PODSENV_PLUGIN_DIR"
    
    if [[ ! -d "$plugin_dir" ]]; then
        return 0
    fi
    
    # Load plugins in alphabetical order
    for plugin_path in "$plugin_dir"/*; do
        if [[ -d "$plugin_path" ]]; then
            local plugin_name="$(basename "$plugin_path")"
            podsenv_load_plugin "$plugin_name"
        fi
    done
}

# Load a specific plugin
podsenv_load_plugin() {
    local plugin_name="$1"
    local plugin_dir="$PODSENV_PLUGIN_DIR/$plugin_name"
    local plugin_init="$plugin_dir/init.sh"
    
    if [[ ! -f "$plugin_init" ]]; then
        return 1
    fi
    
    # Check if plugin is enabled
    if ! podsenv_plugin_enabled "$plugin_name"; then
        return 0
    fi
    
    # Source the plugin initialization script
    source "$plugin_init"
    
    # Register plugin hooks if they exist
    for hook in "${PODSENV_HOOKS[@]}"; do
        local hook_file="$plugin_dir/hooks/$hook.sh"
        if [[ -f "$hook_file" ]]; then
            podsenv_register_hook "$hook" "$hook_file"
        fi
    done
}

# Check if a plugin is enabled
podsenv_plugin_enabled() {
    local plugin_name="$1"
    local plugin_dir="$PODSENV_PLUGIN_DIR/$plugin_name"
    local disabled_file="$plugin_dir/.disabled"
    
    # Plugin is enabled if .disabled file doesn't exist
    [[ ! -f "$disabled_file" ]]
}

# Enable a plugin
podsenv_enable_plugin() {
    local plugin_name="$1"
    local plugin_dir="$PODSENV_PLUGIN_DIR/$plugin_name"
    local disabled_file="$plugin_dir/.disabled"
    
    if [[ ! -d "$plugin_dir" ]]; then
        echo "Plugin '$plugin_name' not found" >&2
        return 1
    fi
    
    rm -f "$disabled_file"
    echo "Plugin '$plugin_name' enabled"
}

# Disable a plugin
podsenv_disable_plugin() {
    local plugin_name="$1"
    local plugin_dir="$PODSENV_PLUGIN_DIR/$plugin_name"
    local disabled_file="$plugin_dir/.disabled"
    
    if [[ ! -d "$plugin_dir" ]]; then
        echo "Plugin '$plugin_name' not found" >&2
        return 1
    fi
    
    touch "$disabled_file"
    echo "Plugin '$plugin_name' disabled"
}

# List all plugins
podsenv_list_plugins() {
    local plugin_dir="$PODSENV_PLUGIN_DIR"
    
    if [[ ! -d "$plugin_dir" ]]; then
        echo "No plugins directory found"
        return 0
    fi
    
    echo "Available plugins:"
    for plugin_path in "$plugin_dir"/*; do
        if [[ -d "$plugin_path" ]]; then
            local plugin_name="$(basename "$plugin_path")"
            local status="enabled"
            
            if ! podsenv_plugin_enabled "$plugin_name"; then
                status="disabled"
            fi
            
            printf "  %-20s %s\n" "$plugin_name" "($status)"
        fi
    done
}

# Register a hook
podsenv_register_hook() {
    local hook_name="$1"
    local hook_file="$2"
    local hooks_dir="$PODSENV_PLUGIN_HOOKS_DIR/$hook_name"
    
    mkdir -p "$hooks_dir"
    
    # Create a symlink to the hook file
    local hook_link="$hooks_dir/$(basename "$(dirname "$hook_file")").sh"
    ln -sf "$hook_file" "$hook_link"
}

# Execute hooks for a specific event
podsenv_execute_hooks() {
    local hook_name="$1"
    shift
    local hook_args="$@"
    
    local hooks_dir="$PODSENV_PLUGIN_HOOKS_DIR/$hook_name"
    
    if [[ ! -d "$hooks_dir" ]]; then
        return 0
    fi
    
    # Execute all hooks for this event
    for hook_file in "$hooks_dir"/*.sh; do
        if [[ -f "$hook_file" ]]; then
            source "$hook_file" $hook_args
        fi
    done
}

# Install a plugin from a git repository
podsenv_install_plugin() {
    local plugin_url="$1"
    local plugin_name="$2"
    
    if [[ -z "$plugin_name" ]]; then
        plugin_name="$(basename "$plugin_url" .git)"
    fi
    
    local plugin_dir="$PODSENV_PLUGIN_DIR/$plugin_name"
    
    if [[ -d "$plugin_dir" ]]; then
        echo "Plugin '$plugin_name' already exists" >&2
        return 1
    fi
    
    echo "Installing plugin '$plugin_name' from $plugin_url..."
    
    if ! git clone "$plugin_url" "$plugin_dir"; then
        echo "Failed to install plugin '$plugin_name'" >&2
        return 1
    fi
    
    echo "Plugin '$plugin_name' installed successfully"
    
    # Load the newly installed plugin
    podsenv_load_plugin "$plugin_name"
}

# Uninstall a plugin
podsenv_uninstall_plugin() {
    local plugin_name="$1"
    local plugin_dir="$PODSENV_PLUGIN_DIR/$plugin_name"
    
    if [[ ! -d "$plugin_dir" ]]; then
        echo "Plugin '$plugin_name' not found" >&2
        return 1
    fi
    
    echo "Uninstalling plugin '$plugin_name'..."
    
    # Remove plugin directory
    rm -rf "$plugin_dir"
    
    # Remove plugin hooks
    for hook in "${PODSENV_HOOKS[@]}"; do
        local hook_link="$PODSENV_PLUGIN_HOOKS_DIR/$hook/$plugin_name.sh"
        rm -f "$hook_link"
    done
    
    echo "Plugin '$plugin_name' uninstalled successfully"
}

# Update a plugin
podsenv_update_plugin() {
    local plugin_name="$1"
    local plugin_dir="$PODSENV_PLUGIN_DIR/$plugin_name"
    
    if [[ ! -d "$plugin_dir" ]]; then
        echo "Plugin '$plugin_name' not found" >&2
        return 1
    fi
    
    if [[ ! -d "$plugin_dir/.git" ]]; then
        echo "Plugin '$plugin_name' is not a git repository" >&2
        return 1
    fi
    
    echo "Updating plugin '$plugin_name'..."
    
    cd "$plugin_dir"
    if ! git pull; then
        echo "Failed to update plugin '$plugin_name'" >&2
        return 1
    fi
    
    echo "Plugin '$plugin_name' updated successfully"
}

# Update all plugins
podsenv_update_all_plugins() {
    local plugin_dir="$PODSENV_PLUGIN_DIR"
    
    if [[ ! -d "$plugin_dir" ]]; then
        echo "No plugins directory found"
        return 0
    fi
    
    for plugin_path in "$plugin_dir"/*; do
        if [[ -d "$plugin_path" ]]; then
            local plugin_name="$(basename "$plugin_path")"
            podsenv_update_plugin "$plugin_name"
        fi
    done
}