# Shell behaviour that oh-my-zsh's lib/ used to provide.
#
# Only what was actually in use. Of omz's 21 lib files this reproduces six;
# the rest were dead weight here -- cli.zsh's 944 lines exist to serve the
# `omz` command itself, diagnostics.zsh another 353 for a bug-report dump,
# and clipboard/spectrum/async_prompt were never reached.
#
# Loading omz to get these cost 250ms before the shell would accept a
# command, and about 8ms on every prompt after that.

## Options ###################################################################

# HISTSIZE is what a running shell holds, SAVEHIST what reaches the file. omz
# capped the file at 10000: at the ~360 commands a day this account runs that
# is under a month, and two thirds of the entries are duplicates, so what
# expires first is the rare command worth recalling.
HISTFILE=$HOME/.zsh_history
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

setopt interactive_comments      # allow # comments when typing at the prompt
setopt long_list_jobs            # jobs in long format by default
setopt prompt_subst              # prompts expand $(...); starship relies on it
setopt always_to_end             # completion leaves the cursor after the word
setopt complete_in_word          # complete from where the cursor is, not the end
unsetopt flow_control            # free ^S and ^Q, nothing here wants XON/XOFF

## Completion #################################################################

# Keep the dump out of $HOME.
_dot_zsh_cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
[ -d "$_dot_zsh_cache/completions" ] || mkdir -p "$_dot_zsh_cache/completions"
_dot_zcompdump=$_dot_zsh_cache/zcompdump-$ZSH_VERSION

# Two sources of completion functions, both ahead of the system ones so they
# win: the handful checked into this repo (see completions/), and the ones
# generated from installed tools by dot_gen_completion in pre.zsh. Both have
# to be on fpath before compinit runs, which is why that lives above this.
fpath=("$DOT_ZSH_DIR/completions" "$_dot_zsh_cache/completions" $fpath)

autoload -Uz compinit
# compinit's security check walks every directory in fpath, which is the
# expensive half of it. Do the full run when the dump is older than a day and
# take the cached one otherwise -- the same bargain omz struck, at 24 hours
# rather than 20. `-C` skips both the check and the staleness comparison.
if [[ -n $_dot_zcompdump(#qN.mh+24) ]]; then
    compinit -d "$_dot_zcompdump"
    # Compiling the dump saves reading and parsing it next time.
    [[ -f "$_dot_zcompdump.zwc" && "$_dot_zcompdump.zwc" -nt "$_dot_zcompdump" ]] \
        || zcompile -R -- "$_dot_zcompdump.zwc" "$_dot_zcompdump" 2>/dev/null
else
    compinit -C -d "$_dot_zcompdump"
fi

# Case-insensitive first, then partial-word, then substring. Typing `dow`
# finds Downloads and `f.b` finds foo.bar.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:*:*:*:*' menu select        # arrow-key selectable menu
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$_dot_zsh_cache/zcompcache"
zstyle ':completion:*' special-dirs true          # offer . and .. where useful
zstyle ':completion:*' list-colors 'di=1;36' 'ln=35' 'so=32' 'pi=33' 'ex=31' \
    'bd=34;46' 'cd=34;43' 'su=30;41' 'sg=30;46' 'tw=30;42' 'ow=30;43'
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
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

# up-line-or-beginning-search is the one omz behaviour worth keeping above all
# the others: with a partial command typed, Up walks only the history entries
# that start with it, instead of every line ever run.
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

## Aliases ####################################################################

# ls colours. Both spellings: BSD ls reads LSCOLORS, GNU ls LS_COLORS, and a
# mac with coreutils installed may have either on PATH.
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
if ls --color=auto . >/dev/null 2>&1; then
    alias ls='ls --color=auto'          # GNU
else
    alias ls='ls -G'                    # BSD
fi
alias ll='ls -lh'
alias la='ls -lAh'

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Directory shorthands. `-` is the only one of omz's twenty that showed up in
# the history file, but the rest cost nothing.
alias -- -='cd -'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias d='dirs -v | head -10'
