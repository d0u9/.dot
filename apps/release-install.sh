#!/bin/bash

set -euo pipefail

# DOT_DIR is exported by parent script
# APP_DIR is exported by parent script
# DOT_LOG_LEVEL is exported by parent script
source "$DOT_DIR/apps/shell/release.sh"

info "Installing official prebuilt releases listed in apps/release/tools"

release_sync || warn "some releases failed; rerun 'dgspkg sync' later"

info "Finished"
