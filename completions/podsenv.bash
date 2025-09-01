#!/usr/bin/env bash
# Bash completion for podsenv

_podsenv() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Main commands
    local commands="install uninstall versions global local shell which exec version prefix rehash init doctor help"

    # Handle subcommands
    case "${COMP_CWORD}" in
        1)
            # Complete main commands
            COMPREPLY=($(compgen -W "${commands}" -- ${cur}))
            return 0
            ;;
        2)
            # Complete based on the previous command
            case "${prev}" in
                install)
                    # Complete with available versions (simplified)
                    local versions="1.11.3 1.12.1 1.13.0 1.14.3 1.15.2"
                    COMPREPLY=($(compgen -W "${versions}" -- ${cur}))
                    ;;
                uninstall|global|local|shell|which|exec|prefix)
                    # Complete with installed versions
                    if command -v podsenv >/dev/null 2>&1; then
                        local installed_versions=$(podsenv versions --bare 2>/dev/null || echo "")
                        COMPREPLY=($(compgen -W "${installed_versions}" -- ${cur}))
                    fi
                    ;;
                versions)
                    COMPREPLY=($(compgen -W "--bare --remote" -- ${cur}))
                    ;;
                init)
                    COMPREPLY=($(compgen -W "bash zsh fish" -- ${cur}))
                    ;;
                help)
                    COMPREPLY=($(compgen -W "${commands}" -- ${cur}))
                    ;;
            esac
            ;;
        *)
            # Handle options for specific commands
            case "${COMP_WORDS[1]}" in
                install)
                    COMPREPLY=($(compgen -W "--force --verbose --with-docs" -- ${cur}))
                    ;;
                uninstall)
                    COMPREPLY=($(compgen -W "--force --verbose --all" -- ${cur}))
                    ;;
                global|local|shell)
                    COMPREPLY=($(compgen -W "--unset --verbose" -- ${cur}))
                    ;;
                which)
                    COMPREPLY=($(compgen -W "--all --verbose" -- ${cur}))
                    ;;
                exec)
                    COMPREPLY=($(compgen -W "--version --dry-run --verbose" -- ${cur}))
                    ;;
                version)
                    COMPREPLY=($(compgen -W "--bare --origin --verbose" -- ${cur}))
                    ;;
                prefix)
                    COMPREPLY=($(compgen -W "--all --verbose" -- ${cur}))
                    ;;
                doctor)
                    COMPREPLY=($(compgen -W "--fix --verbose --quiet" -- ${cur}))
                    ;;
            esac
            ;;
    esac
}

# Register the completion function
complete -F _podsenv podsenv