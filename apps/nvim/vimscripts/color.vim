" let g:nord_cursor_line_number_background = 1

set background=dark
" let scheme = "catppuccin-frappe"
" let scheme = "nord"
let scheme = v:lua.THEME()

try
    execute 'colorscheme ' .. scheme
catch
    echo "colorscheme " .. scheme .. " hasn't installed yet"
endtry

