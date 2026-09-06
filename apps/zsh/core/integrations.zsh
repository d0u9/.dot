# Interactive command-line integrations. These tools are installed separately
# from the Zsh plugins and remain optional on each host.

if (( $+commands[fzf] )); then
    () {
        local fzf_init fzf_root
        local -a fzf_roots=(
            "${FZF_BASE:+$FZF_BASE/shell}"
            "$HOME/.fzf/shell"
            "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/opt/fzf/shell}"
            /opt/homebrew/opt/fzf/shell
            /usr/local/opt/fzf/shell
            /home/linuxbrew/.linuxbrew/opt/fzf/shell
            /usr/share/fzf
            /usr/share/fzf/shell
            /usr/share/doc/fzf/examples
        )

        # Recent fzf versions generate the complete integration directly.
        if fzf_init=$(command fzf --zsh 2>/dev/null); then
            eval "$fzf_init"
            return
        fi

        # Older releases ship completion and key bindings as separate files.
        for fzf_root in "${fzf_roots[@]}"; do
            [[ -n $fzf_root ]] || continue
            if [[ -r "$fzf_root/completion.zsh" ||
                  -r "$fzf_root/key-bindings.zsh" ]]; then
                [[ -r "$fzf_root/completion.zsh" ]] &&
                    source "$fzf_root/completion.zsh"
                [[ -r "$fzf_root/key-bindings.zsh" ]] &&
                    source "$fzf_root/key-bindings.zsh"
                return
            fi
        done
    }
fi

# Load eagerly so every visited directory contributes to zoxide's database.
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh --cmd z)"
fi
