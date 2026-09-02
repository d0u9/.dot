set background=dark
" let scheme = "catppuccin-frappe"
let scheme = v:lua.THEME()

try
    execute 'colorscheme ' .. scheme
catch
    echo "colorscheme " .. scheme .. " hasn't installed yet"
endtry

