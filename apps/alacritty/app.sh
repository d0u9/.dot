desc="Alacritty configuration and Catppuccin themes"
link=(".:$HOME/.config/alacritty")

post() {
    local flavour dir="$APP_DIR/plugins/catppuccin"
    mkdir -p "$dir"
    for flavour in latte frappe macchiato mocha; do
        curl -fLo "$dir/catppuccin-$flavour.toml" \
            "https://github.com/catppuccin/alacritty/raw/main/catppuccin-$flavour.toml"
    done
}
