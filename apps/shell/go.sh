# Keep Go's mutable workspace data out of $HOME and installed binaries in the
# account-local executable prefix. mise selects Go versions; it does not own
# these locations.
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export GOBIN="$HOME/.local/bin"
