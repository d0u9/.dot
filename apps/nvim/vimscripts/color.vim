 let g:nord_cursor_line_number_background = 1

set background=dark
try
    colorscheme nord
    let cmd="highlight FoldColumn guifg=" . g:terminal_color_6
    execute cmd
catch
    echo "colorscheme nord hasn't installed yet"
endtry

