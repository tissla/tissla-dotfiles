#!/usr/bin/env bash
set -euo pipefail


# load theme to generate
source theme.env

# remove hash func
strip_hash() {
  echo "${1#\#}"
}


mkdir -p theme

###############################################################################
# theme.toml
###############################################################################
cat > theme/theme.toml <<EOF
[colors.primary]
background = "0x$(strip_hash "$CLR_BG")"
foreground = "0x$(strip_hash "$CLR_FG")"

[colors.normal]
black   = "0x$(strip_hash "$CLR_BG")"
red     = "0xf87171"
green   = "0x34d399"
yellow  = "0xfbbf24"
blue    = "0x1e3a8a"
magenta = "0x8b5cf6"
cyan    = "0x22d3ee"
white   = "0xf9fafb"

[colors.bright]
black   = "0x$(strip_hash "${CLR_PRIMARY_MUTED}")"
red     = "0xf87171"
green   = "0x34d399"
yellow  = "0xfbbf24"
blue    = "0x374151"
magenta = "0xa78bfa"
cyan    = "0x7dd3fc"
white   = "0xffffff"

[font.normal]
family = "$FONT_MONO"
style = "$FONT_STYLE"
EOF

###############################################################################
# theme.conf
###############################################################################
cat > theme/theme.conf <<EOF
\$bg        = rgb($(strip_hash "$CLR_BG"))
\$fg        = rgb($(strip_hash "$CLR_FG"))
\$primary   = rgb($(strip_hash "$CLR_PRIMARY"))
\$secondary = rgb($(strip_hash "$CLR_PRIMARY_MUTED"))

\$bgalpha   = 0xee$(strip_hash "$CLR_BG")
\$mutedalpha = 0xaa$(strip_hash "$CLR_MUTED")

EOF

###############################################################################
# theme.rasi
###############################################################################

FONT_STYLE_ROFI="$(printf '%s' "$FONT_STYLE" | sed 's/.*/\u&/')"

cat > theme/theme.rasi <<EOF
* {
    bg:        ${CLR_BG}E6;
    bg-alt:    ${CLR_BG_DARK}E6;
    fg:        ${CLR_FG};
    primary:   ${CLR_PRIMARY};
    secondary: ${CLR_SECONDARY};
    muted:     ${CLR_MUTED};

	font-mono: "${FONT_MAIN} ${FONT_STYLE_ROFI} ${FONT_SIZE}";
	font-search: "${FONT_MONO} ${FONT_SIZE_TITLE}";
}
EOF

###############################################################################
# Theme.qml
###############################################################################

mkdir -p quickshell

## quickshell specific
cat > quickshell/Theme.qml <<EOF
import QtQuick
pragma Singleton

QtObject {
    id: theme

	property color background: "#CC$(strip_hash "$CLR_BG")"
	property color backgroundSolid: "${CLR_BG}"
	property color backgroundAlt: "#E6$(strip_hash "$CLR_PRIMARY_MUTED")"
	property color backgroundAltSolid: "${CLR_MUTED}"
    property color primary: "${CLR_PRIMARY}"
    property color foreground: "${CLR_FG}"
    property color foregroundAlt: "${CLR_FG_MUTED}"
    property color inactive: "${CLR_INACTIVE}"
	property color accent: "${CLR_ACCENT}"
	property color info: "${CLR_INFO}"
	property color surface: "${CLR_SURFACE}"
	property color active: "${CLR_ACTIVE}"
	property int radius: ${VAL_RAD}
	property int radiusAlt: ${VAL_RAD_ALT}
	property string noteDirectory: "${DIR_OBSIDIAN}"
	property string fontMain: "${FONT_MAIN}"
	property string fontMono: "${FONT_MONO}"
}
EOF



echo "Themes generated!"
