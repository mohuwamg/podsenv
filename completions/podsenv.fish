# Fish completion for podsenv

# Main command completion
complete -c podsenv -f

# Subcommands
complete -c podsenv -n '__fish_use_subcommand' -a 'install' -d 'Install a CocoaPods version'
complete -c podsenv -n '__fish_use_subcommand' -a 'uninstall' -d 'Uninstall CocoaPods versions'
complete -c podsenv -n '__fish_use_subcommand' -a 'versions' -d 'List installed CocoaPods versions'
complete -c podsenv -n '__fish_use_subcommand' -a 'global' -d 'Set or show the global CocoaPods version'
complete -c podsenv -n '__fish_use_subcommand' -a 'local' -d 'Set or show the local CocoaPods version'
complete -c podsenv -n '__fish_use_subcommand' -a 'shell' -d 'Set or show the shell CocoaPods version'
complete -c podsenv -n '__fish_use_subcommand' -a 'which' -d 'Display the full path to a command'
complete -c podsenv -n '__fish_use_subcommand' -a 'exec' -d 'Execute a command with a specific CocoaPods version'
complete -c podsenv -n '__fish_use_subcommand' -a 'version' -d 'Show the current CocoaPods version'
complete -c podsenv -n '__fish_use_subcommand' -a 'prefix' -d 'Display the installation prefix'
complete -c podsenv -n '__fish_use_subcommand' -a 'rehash' -d 'Rebuild shim scripts'
complete -c podsenv -n '__fish_use_subcommand' -a 'init' -d 'Configure shell integration'
complete -c podsenv -n '__fish_use_subcommand' -a 'doctor' -d 'Diagnose podsenv environment'
complete -c podsenv -n '__fish_use_subcommand' -a 'help' -d 'Show help for commands'

# Helper function to get installed versions
function __podsenv_installed_versions
    if command -v podsenv >/dev/null 2>&1
        podsenv versions --bare 2>/dev/null
    end
end

# Helper function to get available versions
function __podsenv_available_versions
    echo -e "1.15.2\n1.14.3\n1.13.0\n1.12.1\n1.11.3\nlatest\nstable"
end

# install command options
complete -c podsenv -n '__fish_seen_subcommand_from install' -l force -d 'Force installation even if version exists'
complete -c podsenv -n '__fish_seen_subcommand_from install' -l verbose -d 'Show detailed installation output'
complete -c podsenv -n '__fish_seen_subcommand_from install' -l with-docs -d 'Install documentation'
complete -c podsenv -n '__fish_seen_subcommand_from install' -a '(__podsenv_available_versions)' -d 'CocoaPods version'

# uninstall command options
complete -c podsenv -n '__fish_seen_subcommand_from uninstall' -l force -d 'Force uninstallation without confirmation'
complete -c podsenv -n '__fish_seen_subcommand_from uninstall' -l verbose -d 'Show detailed uninstallation output'
complete -c podsenv -n '__fish_seen_subcommand_from uninstall' -l all -d 'Uninstall all versions'
complete -c podsenv -n '__fish_seen_subcommand_from uninstall' -a '(__podsenv_installed_versions)' -d 'Installed version'

# versions command options
complete -c podsenv -n '__fish_seen_subcommand_from versions' -l bare -d 'Show versions without additional info'
complete -c podsenv -n '__fish_seen_subcommand_from versions' -l remote -d 'Show available remote versions'

# global command options
complete -c podsenv -n '__fish_seen_subcommand_from global' -l unset -d 'Unset global version'
complete -c podsenv -n '__fish_seen_subcommand_from global' -l verbose -d 'Show detailed version info'
complete -c podsenv -n '__fish_seen_subcommand_from global' -a '(__podsenv_installed_versions)' -d 'Installed version'

# local command options
complete -c podsenv -n '__fish_seen_subcommand_from local' -l unset -d 'Unset local version'
complete -c podsenv -n '__fish_seen_subcommand_from local' -l verbose -d 'Show detailed version info'
complete -c podsenv -n '__fish_seen_subcommand_from local' -a '(__podsenv_installed_versions)' -d 'Installed version'

# shell command options
complete -c podsenv -n '__fish_seen_subcommand_from shell' -l unset -d 'Unset shell version'
complete -c podsenv -n '__fish_seen_subcommand_from shell' -l verbose -d 'Show detailed version info'
complete -c podsenv -n '__fish_seen_subcommand_from shell' -a '(__podsenv_installed_versions)' -d 'Installed version'

# which command options
complete -c podsenv -n '__fish_seen_subcommand_from which' -l all -d 'Show paths in all versions'
complete -c podsenv -n '__fish_seen_subcommand_from which' -l verbose -d 'Show detailed command info'
complete -c podsenv -n '__fish_seen_subcommand_from which' -a 'pod gem bundle rake' -d 'Command name'

# exec command options
complete -c podsenv -n '__fish_seen_subcommand_from exec' -l version -d 'Specify CocoaPods version' -a '(__podsenv_installed_versions)'
complete -c podsenv -n '__fish_seen_subcommand_from exec' -l dry-run -d 'Show what would be executed'
complete -c podsenv -n '__fish_seen_subcommand_from exec' -l verbose -d 'Show detailed execution info'

# version command options
complete -c podsenv -n '__fish_seen_subcommand_from version' -l bare -d 'Show version without additional info'
complete -c podsenv -n '__fish_seen_subcommand_from version' -l origin -d 'Show version source'
complete -c podsenv -n '__fish_seen_subcommand_from version' -l verbose -d 'Show detailed version info'

# prefix command options
complete -c podsenv -n '__fish_seen_subcommand_from prefix' -l all -d 'Show prefixes for all versions'
complete -c podsenv -n '__fish_seen_subcommand_from prefix' -l verbose -d 'Show detailed prefix info'
complete -c podsenv -n '__fish_seen_subcommand_from prefix' -a '(__podsenv_installed_versions)' -d 'Installed version'

# init command options
complete -c podsenv -n '__fish_seen_subcommand_from init' -a 'bash zsh fish' -d 'Shell type'

# doctor command options
complete -c podsenv -n '__fish_seen_subcommand_from doctor' -l fix -d 'Attempt to fix detected issues'
complete -c podsenv -n '__fish_seen_subcommand_from doctor' -l verbose -d 'Show detailed diagnostic info'
complete -c podsenv -n '__fish_seen_subcommand_from doctor' -l quiet -d 'Suppress non-error output'

# help command options
complete -c podsenv -n '__fish_seen_subcommand_from help' -a 'install uninstall versions global local shell which exec version prefix rehash init doctor help' -d 'Command name'