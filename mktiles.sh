#!/bin/sh

# mktiles.sh - generate tiles data definitions and constants
#
# Used in Makefile
# Output:
#     STDOUT: tiles data definitions
#         &3: constants

set -eu

# Generate tiles for a range of bitmap.
# Use -r to reverse the colors.
gentiles() {
    local rev

    if [ "$1" = '-r' ]; then
        shift
        rev=1
    else
        rev=0
    fi
    od -tu1 -j$(($1*8)) -N$((($2-$1+1)*8)) -w8 "$fontf" |
        cut -d' ' -f2- | sed '$d' |
        awk -vrev=$rev '
        BEGIN {OFS=", "}
            {
            if (rev)
                for (i=1; i<=NF; i++)
                    $i=255-$i
            $1="\tdb "$1
            print
            }
        '
    charcnt=$((charcnt+$2-$1+1))
}

fontf="cp437-8x8" # from http://svnweb.freebsd.org/base/head/share/syscons/fonts/cp437-8x8.fnt
charcnt=0

echo "; File generated by mktiles.sh with font file '$(basename $fontf)'

tiles:

; Tiles 0-63: Nintendo character set
"

# ASCII 32-95 with backslash (92) = Yen symbol
# See the "Game Boy Programming Manual", appendix 3, section 10: "CHARACTER CODE
# LIST FOR GAME TITLE REGISTRATION"

gentiles 32 91
gentiles 157 157
gentiles 93 95

echo "
; Tiles 64-127: Nintendo character set in reverse video
"

echo "TILE_ASCII_REV equ $charcnt" >&3

gentiles -r 32 91
gentiles -r 157 157
gentiles -r 93 95

echo "
; Additional characters to draw the box and arrows
"

while read char label; do
    echo "TILE_$label equ $charcnt" >&3
    gentiles $char $char
done <<EOT
27 LARROW
26 RARROW
218 ULEFT
191 URIGHT 
217 LRIGHT
192 LLEFT
196 HORIZ
179 VERT
EOT

echo "TILES_NB equ $charcnt" >&3