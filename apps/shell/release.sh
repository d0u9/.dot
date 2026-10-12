#!/bin/bash

# Install official prebuilt release archives into the ~/.local prefix.
#
#   ~/.local/lib/NAME/TAG/         the unpacked archive, kept whole
#   ~/.local/lib/NAME/current  ->  TAG
#   ~/.local/bin/NAME          ->  ../lib/NAME/current/BIN
#
# A recipe, $RELEASE_DIR/recipes/NAME.sh, sets release_repo (GitHub
# OWNER/REPO) and release_bin (the executable inside the archive), and defines
# release_asset OS ARCH VERSION, which prints the archive name for OS
# (macos|linux), ARCH (arm64|x86_64) and the concrete VERSION. Installing switches `current` and keeps the
# previous version beside it; older ones are removed.
#
# A request is a version or a channel. Channels are moving names such as
# stable or nightly; they are resolved to a concrete version first, and only
# concrete versions name directories, so a channel is upgraded when it moves.
# A recipe may set release_channels (default "latest stable"), release_default
# (default latest) and define release_resolve CHANNEL, printing VERSION TAG:
# the directory name and the release tag to download from.

source "$DOT_DIR/apps/shell/install.sh"

RELEASE_DIR=${RELEASE_DIR:-$DOT_DIR/apps/release}
RELEASE_LIB=$HOME/.local/lib
RELEASE_BIN=$HOME/.local/bin

release_load() {
    local recipe="$RELEASE_DIR/recipes/$1.sh"
    unset release_repo release_bin
    unset -f release_asset release_resolve
    release_name=$1
    release_channels="latest stable"
    release_default=latest
    [ -f "$recipe" ] || { error "release: no recipe for $1: $recipe"; return 1; }
    source "$recipe"
    [ -n "${release_repo:-}" ] && [ -n "${release_bin:-}" ] && declare -F release_asset > /dev/null ||
        { error "release: recipe $recipe must set release_repo, release_bin and release_asset"; return 1; }
    case $(uname -s) in
        Darwin) release_os=macos ;;
        Linux) release_os=linux ;;
        *) error "release: unsupported OS: $(uname -s)"; return 1 ;;
    esac
    case $(uname -m) in
        arm64|aarch64) release_arch=arm64 ;;
        x86_64|amd64) release_arch=x86_64 ;;
        *) error "release: unsupported architecture: $(uname -m)"; return 1 ;;
    esac
}

# Print VERSION TAG for the latest GitHub release. The redirect is not
# subject to the API rate limit.
release_github_latest() {
    local url
    url=$(curl -fsS -o /dev/null -w '%{redirect_url}' "https://github.com/$release_repo/releases/latest") &&
        [ -n "$url" ] || { error "release: cannot resolve the latest $release_repo release" >&2; return 1; }
    printf '%s %s\n' "${url##*/}" "${url##*/}"
}

# Print VERSION TAG for REQUEST (default: the recipe's release_default).
release_target() {
    local request="${1:-$release_default}"
    case " $release_channels " in *" $request "*)
        if declare -F release_resolve > /dev/null; then release_resolve "$request"; else release_github_latest; fi
        return ;;
    esac
    case $request in
        *[0-9]*) release_github_tag "$request" ;;
        *) error "release: unknown channel $request (supported: $release_channels)" >&2; return 1 ;;
    esac
}

# Print VERSION TAG for the release tagged VERSION, also trying it with the
# leading v added or removed, since projects differ (v10.5.0 against 15.2.0).
# A version already on disk is used without asking GitHub.
release_github_tag() {
    local tag
    for tag in "$1" "$([ "${1#v}" = "$1" ] && echo "v$1" || echo "${1#v}")"; do
        if [ -d "$RELEASE_LIB/$release_name/$tag" ] ||
            curl -fsS -o /dev/null -I "https://github.com/$release_repo/releases/tag/$tag" 2> /dev/null; then
            printf '%s %s\n' "$tag" "$tag"
            return 0
        fi
    done
    error "release: no release $1 in $release_repo" >&2
    return 1
}

# Print the Rust target triple for OS ARCH, which many projects name their
# assets after: aarch64-apple-darwin, x86_64-unknown-linux-musl (static).
release_rust_target() {
    local cpu=$2
    [ "$cpu" = arm64 ] && cpu=aarch64
    case $1 in
        macos) printf '%s-apple-darwin\n' "$cpu" ;;
        linux) printf '%s-unknown-linux-musl\n' "$cpu" ;;
    esac
}

# Print the sha256 GitHub records for ASSET in TAG, or nothing when absent.
release_digest() {
    curl -fsS "https://api.github.com/repos/$release_repo/releases/tags/$1" 2> /dev/null |
        awk -v asset="$2" '
            /"name":/   { name = $0; sub(/.*"name": *"/, "", name); sub(/".*/, "", name) }
            /"digest":/ { if (name == asset) { sub(/.*"sha256:/, ""); sub(/".*/, ""); print; exit } }'
}

release_sha256() {
    if command_exist sha256sum; then sha256sum -- "$1"; else shasum -a 256 -- "$1"; fi | cut -d' ' -f1
}

# Print the request saved by NAME's last install, or nothing.
release_channel() {
    cat -- "$RELEASE_LIB/$1/channel" 2> /dev/null || true
}

release_current() {
    local link="$RELEASE_LIB/$1/current"
    [ -L "$link" ] && readlink "$link" || true
}

# Download TAG and unpack it into the directory for VERSION.
release_fetch() (
    local name="$1" version="$2" tag="$3" asset tmp expected actual root
    local dir="$RELEASE_LIB/$name/$version"
    asset=$(release_asset "$release_os" "$release_arch" "$version")
    tmp=$(mktemp -d) || return 1
    trap 'rm -rf -- "$tmp"' EXIT
    info "downloading $asset ($version)"
    curl -fL --progress-bar -o "$tmp/$asset" \
        "https://github.com/$release_repo/releases/download/$tag/$asset" || return 1
    expected=$(release_digest "$tag" "$asset")
    if [ -n "$expected" ]; then
        actual=$(release_sha256 "$tmp/$asset")
        [ "$actual" = "$expected" ] || { error "release: sha256 mismatch for $asset"; return 1; }
    else
        warn "release: no published sha256 for $asset; not verified"
    fi
    mkdir "$tmp/unpacked" || return 1
    case $asset in
        *.zip) unzip -q "$tmp/$asset" -d "$tmp/unpacked" || return 1 ;;
        *) tar -xf "$tmp/$asset" -C "$tmp/unpacked" || return 1 ;;
    esac
    # Use the archive's single top-level directory as the version directory.
    set -- "$tmp/unpacked"/*
    if [ $# -eq 1 ] && [ -d "$1" ]; then root=$1; else root=$tmp/unpacked; fi
    [ -x "$root/$release_bin" ] || { error "release: $release_bin not found in $asset"; return 1; }
    mkdir -p -- "$RELEASE_LIB/$name" && mv -- "$root" "$dir"
)

# Install NAME at a version or channel (default: the one saved by the last
# install, else the recipe's default); an installed target is a no-op. The
# request is saved in $RELEASE_LIB/NAME/channel, so an upgrade follows it.
release_install() {
    local name="$1" request target version tag previous link old
    release_load "$name" || return 1
    request=${2:-$(release_channel "$name")}
    target=$(release_target "$request") || return 1
    version=${target%% *} tag=${target#* }
    previous=$(release_current "$name")
    link="$RELEASE_BIN/$name"
    if [ -e "$link" ] && [ ! -L "$link" ]; then
        error "release: $link exists and is not a symlink; remove it first"
        return 1
    fi
    if [ "$previous" = "$version" ] && [ -L "$link" ]; then
        [ -z "$request" ] || echo "$request" > "$RELEASE_LIB/$name/channel"
        info "$name $version is up to date"
        return 0
    fi
    [ -d "$RELEASE_LIB/$name/$version" ] || release_fetch "$name" "$version" "$tag" || return 1
    ln -sfn "$version" "$RELEASE_LIB/$name/current" &&
        mkdir -p -- "$RELEASE_BIN" &&
        ln -sfn "../lib/$name/current/$release_bin" "$link" || return 1
    for old in "$RELEASE_LIB/$name"/*; do
        case ${old##*/} in current|channel|"$version"|"$previous") ;; *) rm -rf -- "$old" ;; esac
    done
    [ -z "$request" ] || echo "$request" > "$RELEASE_LIB/$name/channel"
    info "$name ${previous:+$previous -> }$version"
}

release_uninstall() {
    local name="$1" link="$RELEASE_BIN/$1"
    if [ -L "$link" ]; then
        case $(readlink "$link") in "../lib/$name/"*) rm -- "$link" ;; esac
    fi
    [ -d "$RELEASE_LIB/$name" ] || { warn "release: $name is not installed"; return 0; }
    rm -rf -- "${RELEASE_LIB:?}/$name" && info "$name uninstalled"
}

# List the versions of NAME on disk, marking the current one with `*`.
release_versions() {
    local name="$1" current dir found=
    current=$(release_current "$name")
    for dir in "$RELEASE_LIB/$name"/*; do
        [ -d "$dir" ] && [ ! -L "$dir" ] || continue
        found=1
        if [ "${dir##*/}" = "$current" ]; then printf '* %s\n' "${dir##*/}"; else printf '  %s\n' "${dir##*/}"; fi
    done
    [ -n "$found" ] || { warn "release: $name is not installed"; return 1; }
}

# List NAME's channels and latest published releases, marking those on disk.
release_remote() {
    local name="$1" tag mark channel target current
    release_load "$name" || return 1
    for channel in $release_channels; do
        target=$(release_target "$channel") || continue
        printf '%-8s -> %s%s\n' "$channel" "${target%% *}" \
            "$([ "$channel" = "$release_default" ] && echo '  (default)')"
    done
    current=$(release_current "$name")
    # ponytail: tags without a digit (stable, nightly) are moving aliases and
    # are skipped; prereleases and drafts too. Shows the last 30 releases.
    curl -fsS "https://api.github.com/repos/$release_repo/releases?per_page=30" |
        awk '/"tag_name":/ { tag = $0; sub(/.*"tag_name": *"/, "", tag); sub(/".*/, "", tag); skip = 0 }
             /"draft": *true/ { skip = 1 }
             /"prerelease":/ { if (!skip && $0 ~ /false/ && tag ~ /[0-9]/) print tag }' |
        while read -r tag; do
            mark=' '
            [ -d "$RELEASE_LIB/$name/$tag" ] && mark=+
            [ "$tag" = "$current" ] && mark='*'
            printf '%s %s\n' "$mark" "$tag"
        done
}

# Upgrade every installed tool along its saved channel.
release_upgrade_all() {
    local link name rc=0
    for link in "$RELEASE_LIB"/*/current; do
        [ -L "$link" ] || continue
        name=$(basename -- "$(dirname -- "$link")")
        [ -f "$RELEASE_DIR/recipes/$name.sh" ] || continue
        release_install "$name" || rc=1
    done
    return "$rc"
}

release_list() {
    local check="${1:-}" name wanted installed target status recipe
    local fmt='%-12s %-8s %-30s %-30s %s\n'
    local -a names=()
    # Every tool with a recipe, plus anything installed.
    for recipe in "$RELEASE_DIR/recipes"/*.sh; do
        [ -f "$recipe" ] && names+=("$(basename -- "$recipe" .sh)")
    done
    for installed in "$RELEASE_LIB"/*/current; do
        [ -L "$installed" ] && names+=("$(basename -- "$(dirname -- "$installed")")")
    done
    printf "$fmt" TOOL CHANNEL INSTALLED TARGET STATUS
    printf '%s\n' ${names[@]+"${names[@]}"} | sort -u | while read -r name; do
        wanted=$(release_channel "$name")
        installed=$(release_current "$name")
        target= status=
        if [ -n "$check" ]; then
            release_load "$name" > /dev/null 2>&1 && target=$(release_target "$wanted") && target=${target%% *}
            if [ -z "$target" ]; then status='cannot resolve'
            elif [ -z "$installed" ]; then status=available
            elif [ "$installed" = "$target" ]; then status='up to date'
            else status='update available'
            fi
        fi
        [ -z "$installed" ] || wanted=${wanted:-default}
        printf "$fmt" "$name" "${wanted:--}" "${installed:--}" "${target:--}" "$status"
    done
}
