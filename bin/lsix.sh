#!/usr/bin/env bash

# The following defaults may be overridden if autodetection succeeds.
numcolors=16     # Default number of colors in the palette.
background=white # Default montage background.
foreground=black # Default text color.
width=800	 # Default width of screen in pixels.

# Feel free to edit these defaults to your liking.
tilesize=120	       # Width and height of each tile in the montage.
tilewidth=$tilesize    # (or specify separately, if you prefer)
tileheight=$tilesize

# If you get questionmarks for Unicode filenames, try using a different font.
# You can list fonts available using `convert -list font`.
#fontfamily=Droid-Sans-Fallback		# Great Asian font coverage
#fontfamily=Dejavu-Sans			# Wide coverage, comes with GNU/Linux
#fontfamily=Mincho			# Wide coverage, comes with MS Windows

# Default font size is based on width of each tile in montage.
fontsize=$((tilewidth/10))
#fontsize=16		     # (or set the point size directly, if you prefer)

timeout=0.25		    # How long to wait for terminal to respond
			    # to a control sequence (in seconds).

# Sanity checks and compatibility
if [[ ${BASH_VERSINFO[0]} -eq 3 ]]; then
    if bash --version | head -1 | grep -q "version 3"; then
	cat <<-EOF >&2
	Error: The version of Bash is extremely out of date.
	(2007, the same year Steve Jobs announced the iPhone!)

	This is almost always due to Apple's MacOS being silly.
	Please let Apple know that their users expect current UNIX tools.

	In the meantime, try using "brew install bash".
	EOF
	exit 1
    else
	exec bash "$0" "$@"  || echo "Exec failed" >&2
	exit 1
    fi
fi

shopt -s expand_aliases		# Allow aliases for working around quirks.

# For ImageMagick 6 <-> 7 compatibility.
if type magick &>/dev/null; then
    alias convert='magick'
    alias montage='magick montage'
fi

if ! command -v magick montage &>/dev/null; then 	# (implicit 'or')
    echo "Please install ImageMagick" >&2
    exit 1
fi

if type gsed &>/dev/null; then
    alias sed=gsed		# Use GNU sed for MacOS & BSD.
fi

cleanup() {
    echo -n $'\e\\'		# Escape sequence to stop SIXEL.
    stty echo			# Reset terminal to show characters.
    exit 0
}
trap cleanup SIGINT SIGHUP SIGABRT EXIT

autodetect() {
    # Various terminal automatic configuration routines.

    # Don't show escape sequences the terminal doesn't understand.
    stty -echo			# Hush-a Mandara Ni Pari

    # IS TERMINAL SIXEL CAPABLE?		# Send Device Attributes
    IFS=";?c" read -a REPLY -s -t 1 -d "c" -p $'\e[c' >&2
    for code in "${REPLY[@]}"; do
	if [[ $code == "4" ]]; then
	    hassixel=yup
	    break
	fi
    done

    # YAFT is vt102 compatible, cannot respond to vt220 escape sequence.
    if [[ "$TERM" == yaft* ]]; then hassixel=yeah; fi

    if [[ -z "$hassixel" && -z "$LSIX_FORCE_SIXEL_SUPPORT" ]]; then
	cat <<-EOF >&2
	Error: Your terminal does not report having sixel graphics support.

	Please use a sixel capable terminal, such as xterm -ti vt340, or
	ask your terminal manufacturer to add sixel support.

	You may test your terminal by viewing a single image, like so:

		convert foo.jpg  -geometry 800x480  sixel:-

	If your terminal actually does support sixel, please file a bug
	report at http://github.com/hackerb9/lsix/issues
	EOF
	read -s -t 1 -d "c" -p $'\e[c' >&2
	if [[ "$REPLY" ]]; then
	    echo
	    cat -v <<< "Please mention device attribute codes: ${REPLY}c"
	fi

	exit 1
    fi

    # SIXEL SCROLLING (~DECSDM) is now presumed to be enabled.
    # See https://github.com/hackerb9/lsix/issues/41 for details.

    # TERMINAL COLOR AUTODETECTION.
    # Find out how many color registers the terminal has
    IFS=";"  read -a REPLY -s -t ${timeout} -d "S" -p $'\e[?1;1;0S' >&2
    [[ ${REPLY[1]} == "0" ]] && numcolors=${REPLY[2]}

    # YAFT is vt102 compatible, cannot respond to vt220 escape sequence.
    if [[ "$TERM" == yaft* ]]; then numcolors=256; fi

    # Increase colors, if needed
    if [[ $numcolors -lt 256 ]]; then
	# Attempt to set the number of colors to 256.
	# This will work for xterm, but fail on a real vt340.
	IFS=";"  read -a REPLY -s -t ${timeout} -d "S" -p $'\e[?1;3;256S' >&2
	[[ ${REPLY[1]} == "0" ]] && numcolors=${REPLY[2]}
    fi

    # Query the terminal background and foreground colors.
    IFS=";:/"  read -a REPLY -r -s -t ${timeout} -d "\\" -p $'\e]11;?\e\\' >&2
    if [[ ${REPLY[1]} =~ ^rgb ]]; then
	# Return value format: $'\e]11;rgb:ffff/0000/ffff\e\\'.
	# ImageMagick wants colors formatted as #ffff0000ffff.
	background='#'${REPLY[2]}${REPLY[3]}${REPLY[4]%%$'\e'*}
	IFS=";:/"  read -a REPLY -r -s -t ${timeout} -d "\\" -p $'\e]10;?\e\\' >&2
	if [[ ${REPLY[1]} =~ ^rgb ]]; then
	    foreground='#'${REPLY[2]}${REPLY[3]}${REPLY[4]%%$'\e'*}
	    # Check for "Reverse Video" (DECSCNM screen mode).
	    IFS=";?$"  read -a REPLY -s -t ${timeout} -d "y" -p $'\e[?5$p'
	    if [[ ${REPLY[2]} == 1 || ${REPLY[2]} == 3 ]]; then
		temp=$foreground
		foreground=$background
		background=$temp
	    fi
	fi
    fi
    # YAFT is vt102 compatible, cannot respond to vt220 escape sequence.
    if [[ "$TERM" == yaft* ]]; then background=black; foreground=white; fi

    # Send control sequence to query the sixel graphics geometry to
    # find out how large of a sixel image can be shown.
    IFS=";"  read -a REPLY -s -t ${timeout} -d "S" -p $'\e[?2;1;0S' >&2
    if [[ ${REPLY[2]} -gt 0 ]]; then
	width=${REPLY[2]}
    else
	# Nope. Fall back to dtterm WindowOps to approximate sixel geometry.
	IFS=";" read -a REPLY -s -t ${timeout} -d "t" -p $'\e[14t' >&2
	if [[ $? == 0  &&  ${REPLY[2]} -gt 0 ]]; then
	    width=${REPLY[2]}
	fi
    fi

    # BUG WORKAROUND: XTerm cannot show images wider than 1000px.
    # Remove this hack once XTerm gets fixed. Last checked: XTerm(344)
    if [[ $TERM =~ xterm && $width -ge 1000 ]]; then  width=1000; fi

    # Space on either side of each tile is less than 0.5% of total screen width
    tilexspace=$((width/201))
    tileyspace=$((tilexspace/2))
    # Figure out how many tiles we can fit per row. ("+ 1" is for -shadow).
    numtiles=$((width/(tilewidth + 2*tilexspace + 1)))
}

main() {
    # Discover and setup the terminal
    autodetect

    if [[ $# == 0 ]]; then
	# No command line args? Use a sorted list of image files in CWD.
	shopt -s nullglob nocaseglob nocasematch
	set -- *{jpg,jpeg,png,gif,webp,tiff,tif,p?m,x[pb]m,bmp,ico,svg,eps}
	[[ $# != 0 ]] || exit
	readarray -t < <(printf "%s\n" "$@" | sort)

	# Only show first frame of animated GIFs if filename not specified.
	for x in ${!MAPFILE[@]}; do
	    if [[ ${MAPFILE[$x]} =~ (gif|webp)$ ]]; then
		MAPFILE[$x]="${MAPFILE[$x]}[0]"
	    fi
	done
	set -- "${MAPFILE[@]}"
    else
	# Command line args specified. Check for directories.
	lsix=$(realpath "$0")
	for arg; do
	    if [ -d "$arg" ]; then
		echo Recursing on $arg
		(cd "$arg"; $lsix)
	    else
		nodirs+=("$arg")
	    fi
	done
	set -- "${nodirs[@]}"
    fi


    # Resize on load: Save memory by appending this suffix to every filename.
    resize="[${tilewidth}x${tileheight}]"

    imoptions="-tile ${numtiles}x1" # Each montage is 1 row x $numtiles columns
    imoptions+=" -geometry ${tilewidth}x${tileheight}>+${tilexspace}+${tileyspace}" # Size of each tile and spacing
    imoptions+=" -background $background -fill $foreground" # Use terminal's colors
    imoptions+=" -auto-orient "	# Properly rotate JPEGs from cameras
    if [[ $numcolors -gt 16 ]]; then
	imoptions+=" -shadow "		# Just for fun :-)
    fi

    # See top of this file to change fontfamily and fontsize.
    [[ "$fontfamily" ]]  &&  imoptions+=" -font $fontfamily "
    [[ "$fontsize" ]] &&     imoptions+=" -pointsize $fontsize "

    # Create and display montages one row at a time.
    while [ $# -gt 0 ]; do
	# While we still have images to process...
	onerow=()
	goal=$(($# - numtiles)) # How many tiles left after this row
	while [ $# -gt 0  -a  $# -gt $goal ]; do
	    len=${#onerow[@]}
	    onerow[len++]="-label"
	    onerow[len++]=$(processlabel "$1")
	    onerow[len++]="file://$1"
	    shift
	done
	montage "${onerow[@]}"  $imoptions gif:-  \
	    | convert - -colors $numcolors sixel:-
    done
}

processlabel() {
    # This routine is mostly to appease ImageMagick.
    # 1. Remove silly [0] suffix and : prefix.
    # 2. Quote percent backslash, and at sign.
    # 3. Replace control characters with question marks.
    # 4. If a filename is too long, remove extension (.jpg).
    # 5. Split long filenames with newlines (recursively)
    span=15			# filenames longer than span will be split
    echo -n "$1" |
	sed 's|^:||; s|\[0]$||;' | tr '[:cntrl:]' '?' |
	awk -v span=$span -v ORS=""  '
	function halve(s,      l,h) {	# l and h are locals
	    l=length(s);  h=int(l/2);
	    if (l <= span) { return s; }
	    return halve(substr(s, 1, h))  "\n"  halve(substr(s, h+1));
	}
	{
	  if ( length($0) > span ) gsub(/\..?.?.?.?$/, "");
	  print halve($0);
	}
	' |
	sed 's|%|%%|g; s|\\|\\\\|g; s|@|\\@|g;'
}

main "$@"

# Send an escape sequence and wait for a response from the terminal
# so that the program won't quit until images have finished transferring.
read -s -t 60 -d "c" -p $'\e[c' >&2
