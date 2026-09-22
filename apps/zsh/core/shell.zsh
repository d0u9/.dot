# Core shell behaviour, options, completion and key bindings.

## Options ###################################################################

# HISTSIZE is what a running shell holds, SAVEHIST what reaches the file. Keep
# enough unique entries to retain more than a month of history.
#
# The rest of this configuration keeps its state under XDG, and new hosts get
# the history there too. An existing $HOME/.zsh_history stays where it is:
# moving it would either strand the old history or rewrite a file this
# configuration does not own. Delete or move that file to migrate a host.
if [[ -f $HOME/.zsh_history ]]; then
    HISTFILE=$HOME/.zsh_history
else
    HISTFILE=${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history
    [[ -d ${HISTFILE:h} ]] || mkdir -p "${HISTFILE:h}"
fi
HISTSIZE=200000
SAVEHIST=100000

setopt extended_history          # record timestamp and duration per entry
setopt hist_expire_dups_first    # when trimming, drop duplicates before uniques
setopt hist_ignore_all_dups      # keep only the most recent copy of a command
setopt hist_find_no_dups         # do not show the same line twice when searching
setopt hist_ignore_space         # a leading space keeps a command out of history
setopt hist_reduce_blanks        # collapse redundant whitespace before storing
setopt hist_verify               # put ! expansions in the buffer, do not run them
setopt share_history             # every shell reads and writes the same file
setopt append_history

setopt auto_cd                   # a bare directory path means cd
setopt auto_pushd                # cd maintains the directory stack
setopt pushd_ignore_dups
setopt pushd_minus               # so that +N and -N read the way people expect
setopt pushd_silent              # do not print the stack after pushd/popd
DIRSTACKSIZE=20

setopt interactive_comments      # allow # comments when typing at the prompt
setopt long_list_jobs            # jobs in long format by default
setopt prompt_subst              # allow parameter expansion in prompts
setopt no_beep                   # keep completion failures silent
setopt no_hist_beep              # keep failed history searches silent
setopt numeric_glob_sort         # file2 sorts before file10
setopt always_to_end             # completion leaves the cursor after the word
setopt complete_in_word          # complete from where the cursor is, not the end
unsetopt flow_control            # free ^S and ^Q, nothing here wants XON/XOFF

## Path #######################################################################

source "$DOT_ZSH_DIR/core/homebrew.zsh"

# ~/.local is this account's install prefix, the role /usr/local plays for the
# system: binaries this user installed without root, outside any package
# manager. It is where rustup, pipx, uv and most `curl | sh` installers put
# things by default, so putting it on $PATH here means none of them has to be
# redirected. Its content is per-architecture and per-host and is never part of
# this repository.
#
# Nothing inside this repository goes on $PATH: its commands, such as
# `bin/zsh-compile`, are run by their full path.
#
# Shared helper skips absent directories and duplicate entries. `path` remains
# tied to $PATH; -U also removes duplicates a private hook may have added.
_dot_prepend_path_if_dir "$HOME/.local/bin"
typeset -gU path PATH

# The same prefix's counterpart of /usr/local/share/zsh/site-functions: completion
# functions and autoloadable functions this user installed, following the
# XDG data directory the plugins already use. It goes in front so a user copy
# wins over the system's, and must be set before compinit below reads fpath.
# (N) and -U behave as they do for path.
fpath=(${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions(N) $fpath)
typeset -gU fpath

## Completion #################################################################

# Keep the dump out of $HOME.
_dot_zsh_cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
[ -d "$_dot_zsh_cache" ] || mkdir -p "$_dot_zsh_cache"
_dot_zcompdump=$_dot_zsh_cache/zcompdump-$ZSH_VERSION

autoload -Uz compinit

# Rebuild the completion dump in a detached background shell, so the shell
# being started never waits for it. The rebuild is what walks every directory
# in $fpath, runs compinit's security check over them, and rewrites the dump:
# 721ms with a cold dump and 78ms with a warm one against 45ms for `-C` here.
#
# $fpath is passed explicitly. A `zsh -f` starts with the default $fpath, and a
# dump generated from that would be missing every completion reached through
# Homebrew's or this account's site-functions directory -- the shell that later
# loads it would silently lose those completions rather than fail.
#
# mkdir is atomic, so a burst of shells starting together produces one
# rebuild. A lock left behind by a killed rebuild is taken over after an hour;
# without that, the dump would never be refreshed again.
#
# The dump moves into place before its compiled form. A shell starting inside
# that window sees a .zwc older than the dump, ignores it, and reads the dump
# itself, which costs one slower startup. The other order would hand it a .zwc
# whose content does not match the dump beside it.
_dot_zsh_rebuild_zcompdump() {
    emulate -L zsh

    local dump=$1
    local lock=$dump.lock
    if ! mkdir "$lock" 2>/dev/null; then
        () {
            emulate -L zsh -o extended_glob
            [[ -n $lock(#qN/mh+1) ]] || return 1
            rmdir "$lock" 2>/dev/null
        } || return 0
        mkdir "$lock" 2>/dev/null || return 0
    fi

    local tmp=$dump.new.$$
    local script="fpath=(${(@q)fpath})
autoload -Uz compinit
compinit -d ${(q)tmp}
zcompile -R -- ${(q)tmp}.zwc ${(q)tmp} 2>/dev/null
mv -f ${(q)tmp} ${(q)dump}
mv -f ${(q)tmp}.zwc ${(q)dump}.zwc 2>/dev/null
rm -f ${(q)tmp} ${(q)tmp}.zwc
rmdir ${(q)lock}"
    # `&!` runs it detached and keeps job control silent.
    zsh -f -c "$script" &!
}

# `-C` skips both the security check and the staleness comparison, which is
# the whole cost above. Take it whenever a dump exists, and let the background
# rebuild replace a dump older than a day for the *next* shell. A dump that
# does not exist yet has to be built here: this shell has no completions
# otherwise.
#
# Nothing is lost against doing the full run in the foreground every 24 hours,
# because that branch also served a dump up to a day old to this shell. A
# completion installed a moment ago appears once the dump is rebuilt; to force
# it now, delete the dump and start a shell.
#
# The `(#q...)` glob-qualifier form needs EXTENDED_GLOB, which this
# configuration does not set globally; without it the test is true for a dump
# of any age and the rebuild would run for every shell. `emulate -L` restores
# the option set on return, so the check runs inside an anonymous function.
if [[ -s $_dot_zcompdump ]]; then
    compinit -C -d "$_dot_zcompdump"
    if () {
        emulate -L zsh -o extended_glob
        [[ -n $_dot_zcompdump(#qN.mh+24) ]]
    }; then
        _dot_zsh_rebuild_zcompdump "$_dot_zcompdump"
    fi
else
    compinit -d "$_dot_zcompdump"
    # Compiling the dump saves reading and parsing it next time.
    [[ -f "$_dot_zcompdump.zwc" && "$_dot_zcompdump.zwc" -nt "$_dot_zcompdump" ]] \
        || zcompile -R -- "$_dot_zcompdump.zwc" "$_dot_zcompdump" 2>/dev/null
fi
unfunction _dot_zsh_rebuild_zcompdump

# Case-insensitive first, then partial-word, then substring. Typing `dow`
# finds Downloads and `f.b` finds foo.bar.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:*:*:*:*' menu select        # arrow-key selectable menu
zstyle ':completion:*' group-name ''              # separate matches by tag
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$_dot_zsh_cache/zcompcache"
zstyle ':completion:*' special-dirs true          # offer . and .. where useful
zstyle ':completion:*' list-colors 'di=1;36' 'ln=35' 'so=32' 'pi=33' 'ex=31' \
    'bd=34;46' 'cd=34;43' 'su=30;41' 'sg=30;46' 'tw=30;42' 'ow=30;43'
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
# Do not offer the current directory back to cd ..
zstyle ':completion:*:cd:*' ignore-parents parent pwd

## Key bindings ###############################################################

# Emacs bindings regardless of $EDITOR: vi mode has a 0.4s escape delay that
# is felt on every keystroke sequence, and nothing here wants it. This comes
# first because selecting a keymap resets it -- every binding below would be
# discarded if it ran afterwards.
bindkey -e

# Read the sequences from terminfo where possible: hard-coding them breaks on
# terminals that disagree, and zsh already knows what this one sends.
typeset -gA _dot_keys=(
    Home      "${terminfo[khome]}"  End       "${terminfo[kend]}"
    Insert    "${terminfo[kich1]}"  Delete    "${terminfo[kdch1]}"
    Up        "${terminfo[kcuu1]}"  Down      "${terminfo[kcud1]}"
    Left      "${terminfo[kcub1]}"  Right     "${terminfo[kcuf1]}"
    Backspace "${terminfo[kbs]}"
)

# With a partial command typed, Up walks only the history entries that start
# with it instead of every line ever run.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n ${_dot_keys[Up]}     ]] && bindkey "${_dot_keys[Up]}"     up-line-or-beginning-search
[[ -n ${_dot_keys[Down]}   ]] && bindkey "${_dot_keys[Down]}"   down-line-or-beginning-search
[[ -n ${_dot_keys[Home]}   ]] && bindkey "${_dot_keys[Home]}"   beginning-of-line
[[ -n ${_dot_keys[End]}    ]] && bindkey "${_dot_keys[End]}"    end-of-line
[[ -n ${_dot_keys[Delete]} ]] && bindkey "${_dot_keys[Delete]}" delete-char
[[ -n ${_dot_keys[Insert]} ]] && bindkey "${_dot_keys[Insert]}" overwrite-mode

# terminfo reports these only while the keypad is in application mode, which
# zsh does not enter by default, so bind what the terminals actually send too.
# The arrows matter most: without these two, Up falls back to plain history
# and the prefix search silently does not happen.
bindkey '^[[A'    up-line-or-beginning-search
bindkey '^[[B'    down-line-or-beginning-search
bindkey '^[OA'    up-line-or-beginning-search
bindkey '^[OB'    down-line-or-beginning-search
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line
bindkey '^[OH'    beginning-of-line
bindkey '^[OF'    end-of-line
bindkey '^[[3~'   delete-char
bindkey '^[[1;5C' forward-word          # Ctrl-Right
bindkey '^[[1;5D' backward-word         # Ctrl-Left
bindkey '^[[1;3C' forward-word          # Alt-Right
bindkey '^[[1;3D' backward-word         # Alt-Left
bindkey '^[[Z'    reverse-menu-complete # Shift-Tab

# Nothing below this file needs these; leaving them in place would put three
# more names -- one of them a 9-element map -- in every interactive shell.
unset _dot_zsh_cache _dot_zcompdump
unset _dot_keys
