# Initialize Homebrew before compinit and before selecting optional tools.
# Prefer the platform prefix even when PATH inherited another installation.
# uname reports the current process architecture on macOS (including Rosetta).
# Do not cache shellenv: its output depends on the incoming shell environment.
() {
    local brew_exe candidate init
    local -a candidates
    case $OSTYPE in
        darwin*)
            case $(/usr/bin/uname -m) in
                arm64|aarch64) candidates=(/opt/homebrew/bin/brew) ;;
                x86_64|i?86) candidates=(/usr/local/bin/brew) ;;
            esac
            ;;
        linux*) candidates=(/home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew") ;;
    esac
    # PATH also supports installations at a non-default prefix. The command
    # hash may retain an uninstalled executable, so check every candidate.
    if (( $+commands[brew] )); then
        candidates+=("${commands[brew]}")
    fi
    for candidate in "${candidates[@]}"; do
        if [[ -f $candidate && -x $candidate ]]; then
            brew_exe=$candidate
            break
        fi
    done
    [[ -n $brew_exe ]] || return 0
    if init=$("$brew_exe" shellenv zsh); then
        eval "$init"
    fi
}
