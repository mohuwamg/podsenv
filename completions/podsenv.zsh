#compdef podsenv
# Zsh completion for podsenv

_podsenv() {
    local context state line
    typeset -A opt_args

    _arguments -C \
        '1: :_podsenv_commands' \
        '*::arg:->args'

    case $state in
        args)
            case $words[1] in
                install)
                    _arguments \
                        '--force[Force installation even if version exists]' \
                        '--verbose[Show detailed installation output]' \
                        '--with-docs[Install documentation]' \
                        '1: :_podsenv_available_versions'
                    ;;
                uninstall)
                    _arguments \
                        '--force[Force uninstallation without confirmation]' \
                        '--verbose[Show detailed uninstallation output]' \
                        '--all[Uninstall all versions]' \
                        '*: :_podsenv_installed_versions'
                    ;;
                versions)
                    _arguments \
                        '--bare[Show versions without additional info]' \
                        '--remote[Show available remote versions]'
                    ;;
                global)
                    _arguments \
                        '--unset[Unset global version]' \
                        '--verbose[Show detailed version info]' \
                        '1: :_podsenv_installed_versions'
                    ;;
                local)
                    _arguments \
                        '--unset[Unset local version]' \
                        '--verbose[Show detailed version info]' \
                        '1: :_podsenv_installed_versions'
                    ;;
                shell)
                    _arguments \
                        '--unset[Unset shell version]' \
                        '--verbose[Show detailed version info]' \
                        '1: :_podsenv_installed_versions'
                    ;;
                which)
                    _arguments \
                        '--all[Show paths in all versions]' \
                        '--verbose[Show detailed command info]' \
                        '1: :_podsenv_commands_list'
                    ;;
                exec)
                    _arguments \
                        '--version[Specify CocoaPods version]:version:_podsenv_installed_versions' \
                        '--dry-run[Show what would be executed]' \
                        '--verbose[Show detailed execution info]' \
                        '*: :_command_names -e'
                    ;;
                version)
                    _arguments \
                        '--bare[Show version without additional info]' \
                        '--origin[Show version source]' \
                        '--verbose[Show detailed version info]'
                    ;;
                prefix)
                    _arguments \
                        '--all[Show prefixes for all versions]' \
                        '--verbose[Show detailed prefix info]' \
                        '1: :_podsenv_installed_versions'
                    ;;
                init)
                    _arguments \
                        '1: :_podsenv_shells'
                    ;;
                doctor)
                    _arguments \
                        '--fix[Attempt to fix detected issues]' \
                        '--verbose[Show detailed diagnostic info]' \
                        '--quiet[Suppress non-error output]'
                    ;;
                help)
                    _arguments \
                        '1: :_podsenv_commands'
                    ;;
            esac
            ;;
    esac
}

_podsenv_commands() {
    local commands
    commands=(
        'install:Install a CocoaPods version'
        'uninstall:Uninstall CocoaPods versions'
        'versions:List installed CocoaPods versions'
        'global:Set or show the global CocoaPods version'
        'local:Set or show the local CocoaPods version'
        'shell:Set or show the shell CocoaPods version'
        'which:Display the full path to a command'
        'exec:Execute a command with a specific CocoaPods version'
        'version:Show the current CocoaPods version'
        'prefix:Display the installation prefix'
        'rehash:Rebuild shim scripts'
        'init:Configure shell integration'
        'doctor:Diagnose podsenv environment'
        'help:Show help for commands'
    )
    _describe 'commands' commands
}

_podsenv_installed_versions() {
    local versions
    if command -v podsenv >/dev/null 2>&1; then
        versions=(${(f)"$(podsenv versions --bare 2>/dev/null)"})
        _describe 'installed versions' versions
    fi
}

_podsenv_available_versions() {
    local versions
    # Common CocoaPods versions
    versions=(
        '1.15.2:Latest stable version'
        '1.14.3:Previous stable version'
        '1.13.0:Older stable version'
        '1.12.1:Legacy version'
        '1.11.3:Legacy version'
        'latest:Latest available version'
        'stable:Latest stable version'
    )
    _describe 'available versions' versions
}

_podsenv_shells() {
    local shells
    shells=(
        'bash:Bash shell'
        'zsh:Zsh shell'
        'fish:Fish shell'
    )
    _describe 'shells' shells
}

_podsenv_commands_list() {
    local commands
    commands=(
        'pod:CocoaPods command'
        'gem:RubyGems command'
        'bundle:Bundler command'
        'rake:Rake command'
    )
    _describe 'commands' commands
}

_podsenv "$@"