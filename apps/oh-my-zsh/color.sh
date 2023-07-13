color() {
color-usage() {
cat <<"USAGE"
Usage: color [OPTIONS] <color>
    -b|--bold	for bold text
	-i|--italic	for italic text
	-u|--underline	for underlined text
	-f|--flash	for blinking text, not possible together with --bg
	-r|--reverse	to switch fg and bg colors
	-/--bg <color>	for background color
	-d|--dark	for fainted / less intense colors (your terminal may not support this)
	-x|--invisible  for invisible text (your terminal may not support this)
	-ff|--fastflash for fast blinking text (your terminal may not support this), not possible together with --bg
Color can be: black, red, green, yellow, blue, magenta, cyan, white and lightblack, lightred etc.
Use "color" without specifying the color to reset to default.
Notes: 
1. You can not use blink in combination with --bg, but you can do -r instead and define <color> as desired bg-color. Example: color -f -r blue lets black text blink on blue background. This means you have the bg color as text color, which can't be changed."
2. Append $(color) behind the string you have formatted, or the color sequence may stay in effect, especially in bash.
3. You can combine options like -b -i -f, but be sensible; -x -f is not sensible; neither is -d lightred.
Examples:
echo "This is $(color -f -i lightred)blinking italic lightred text$(color)"
echo "This is $(color -bg blue white)white text on blue bg$(color)"
echo "This shows words in $(color green)green $(color magenta)magenta $(color)and the rest normal"
echo "This shows $(color -f -r cyan)bold blinking text on cyan background$(color)"
USAGE
}

# Define and create array "colors"
typeset -Ag colors
colors=( black "0" red "1" green "2" yellow "3" blue "4" magenta "5" cyan "6" white "7" )

# Loop to read options and arguments
while [ $1 ]; do
    case "$1" in
	'-h'|'--help') color-usage;;
        '-b'|'--bold') mode="${mode}1;";;
        '-d'|'--dark') mode="${mode}2;";;
        '-i'|'--italic') mode="${mode}3;";;
        '-u'|'--underline') mode="${mode}4;";;
        '-f'|'--flash') mode="${mode}5;";;
        '-ff'|'--fastflash') mode="${mode}6;";;
        '-r'|'--reverse') mode="${mode}7;";;
        '-x'|'--invisible') mode="8;";;
        '-bg'|'--bg') case "$2" in
            light*) bgc=";10${colors[${2#light}]}"; shift;;
            black|red|green|yellow|blue|magenta|cyan|white) bgc=";4${colors[$2]}"; shift;;
            esac;;
        'reset') reset=true;;
        *) case "$1" in
	      light*) fgc=";9${colors[${1#light}]}";;
	      black|red|green|yellow|blue|magenta|cyan|white) fgc=";3${colors[$1]}";;
              *) echo The color loop is buggy or you used it wrong;;
           esac;;
    esac
    shift
done

# Set color sequence
mode="${mode%;}" # strip ";" from mode string if it ends with that
echo -e "\e[${mode:-0}${fgc}${bgc}m" # (default value for mode = 0, so if nothing was set, go default; -e to please bash)
unset mode intensity bgc fgc # clean up
}
