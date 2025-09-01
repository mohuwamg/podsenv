# Example Plugin for podsenv

This is an example plugin that demonstrates how to extend podsenv functionality using the plugin system.

## Features

- Demonstrates plugin initialization
- Shows how to use hooks (after_install)
- Provides example functions
- Logs installation activities

## Installation

This plugin is included as an example. To enable it:

```bash
podsenv plugin enable example-plugin
```

## Usage

Once enabled, the plugin will:

1. Display a loading message when podsenv starts
2. Create welcome files after CocoaPods installations
3. Log installation activities
4. Provide the `example_plugin_info` function

### Available Functions

- `example_plugin_info` - Display plugin information

## Hooks

This plugin implements the following hooks:

- `after_install` - Executed after a CocoaPods version is installed

## Files Created

- `~/.podsenv/plugins/example-plugin/install.log` - Installation log
- `<version_path>/.podsenv-welcome` - Welcome message for each installed version

## Development

This plugin serves as a template for creating your own podsenv plugins. Key components:

1. `init.sh` - Plugin initialization script
2. `hooks/` - Directory containing hook scripts
3. `README.md` - Plugin documentation

## Plugin Structure

```
example-plugin/
├── init.sh                 # Plugin initialization
├── hooks/
│   └── after_install.sh   # Post-installation hook
├── README.md              # This documentation
└── config/                # Plugin configuration (created automatically)
```

## Customization

You can customize this plugin by:

1. Modifying `init.sh` to add your own functions
2. Adding more hooks in the `hooks/` directory
3. Creating configuration files in the `config/` directory

## Available Hooks

- `before_install` - Before CocoaPods installation
- `after_install` - After CocoaPods installation
- `before_uninstall` - Before CocoaPods uninstallation
- `after_uninstall` - After CocoaPods uninstallation
- `before_version_change` - Before version switching
- `after_version_change` - After version switching
- `before_rehash` - Before shim rebuilding
- `after_rehash` - After shim rebuilding

## License

This example plugin is provided as-is for educational purposes.