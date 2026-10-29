desc="mise binary and global language runtimes (shims on PATH)"
release=(mise)
link_replace=0
link=("conf.toml:$HOME/.config/mise/conf.d/00-dot.toml")
items=(node:on python go:on)

# Run from $HOME: mise also reads the config of every directory above the
# working directory, which could shadow the global one being changed.
item_install() {
    local spec=$1@latest
    [ "$1" = node ] && spec=node@lts
    (cd -- "$HOME" && mise use -g "$spec")
}
item_uninstall() { (cd -- "$HOME" && mise unuse -g "$1"); }
