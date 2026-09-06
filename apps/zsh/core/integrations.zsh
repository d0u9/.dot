# Interactive command-line integrations. These tools are installed separately
# from the Zsh plugins and remain optional on each host.

# The tool init caches are shared with core/aliases.zsh, which loads first and
# has normally sourced this already; sourcing it again is a few hundred
# microseconds and keeps this file independent of that order.
source "$DOT_ZSH_DIR/lib/toolcache.zsh"

if (( $+commands[fzf] )); then
    # Recent fzf versions generate the complete integration directly.
    if ! _dot_source_tool_init fzf-init fzf fzf --zsh; then
        # Older releases ship completion and key bindings as separate files.
        () {
            local fzf_root
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
fi

# Load eagerly so every visited directory contributes to zoxide's database.
if (( $+commands[zoxide] )) &&
   _dot_source_tool_init zoxide-init zoxide zoxide init zsh --cmd z; then

    # Record the directory in the background. zoxide's own chpwd hook runs
    # `zoxide add` synchronously, and that binary takes about 29ms to start
    # here against 3.5ms for a plain fork, so every `cd` paid ~30ms before the
    # next prompt could be drawn. Backgrounding costs about 1ms and takes it
    # off the path between Enter and the prompt.
    #
    # The trade is that the database is written a moment later than the `cd`:
    # a `z` typed immediately after a `cd` to a brand new directory may not see
    # it yet, and a burst of `cd`s has several writers at once -- zoxide
    # installs its database by rename, so the worst case is a lost visit count,
    # not a damaged file.
    #
    # zoxide's hook is copied rather than reimplemented, so whatever a future
    # version does inside it still runs. `&!` also disowns, which keeps job
    # control silent. Re-sourcing this file is safe: the init script above
    # restores zoxide's own definition first, so the copy is always the real
    # hook and never the wrapper -- the latter would recurse.
    # Only wrap after successful initialization: on failure a previous wrapper
    # can still be installed, and copying it would create recursive jobs.
    if (( $+functions[__zoxide_hook] )); then
        functions[_dot_zoxide_add]=$functions[__zoxide_hook]
        __zoxide_hook() { _dot_zoxide_add &! }
    fi
fi

unfunction _dot_source_tool_init
