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
# theme.css
###############################################################################
cat > theme/theme.css <<EOF
@define-color theme-background ${CLR_BG};
@define-color theme-foreground ${CLR_FG_MUTED};
@define-color theme-primary    ${CLR_PRIMARY};
@define-color theme-secondary  ${CLR_SECONDARY};
@define-color theme-accent     ${CLR_ACCENT};
@define-color theme-muted      ${CLR_MUTED};
@define-color theme-border     ${CLR_BORDER};
@define-color theme-success    ${CLR_SUCCESS};
@define-color theme-warning    ${CLR_WARNING};
@define-color theme-error      ${CLR_ERROR};

EOF

###############################################################################
# theme.conf
###############################################################################
cat > theme/theme.conf <<EOF
\$bg        = rgb($(strip_hash "$CLR_BG"))
\$fg        = rgb($(strip_hash "$CLR_FG"))
\$primary   = rgb($(strip_hash "$CLR_PRIMARY"))
\$secondary = rgb($(strip_hash "$CLR_PRIMARY_MUTED"))
\$accent    = rgb($(strip_hash "$CLR_ACCENT"))
\$muted     = rgb($(strip_hash "$CLR_MUTED"))
\$border    = rgb($(strip_hash "$CLR_BORDER"))
\$success   = rgb($(strip_hash "$CLR_SUCCESS"))
\$warning   = rgb($(strip_hash "$CLR_WARNING"))
\$error     = rgb($(strip_hash "$CLR_ERROR"))

\$bgalpha   = 0xee$(strip_hash "$CLR_BG")
\$mutedalpha = 0xaa$(strip_hash "$CLR_MUTED")

EOF

###############################################################################
# theme.rasi
###############################################################################

cat > theme/theme.rasi <<EOF
* {
    bg:        ${CLR_ROFI_BG};
    bg-alt:    ${CLR_ROFI_BG_ALT};
    fg:        ${CLR_FG};
    primary:   ${CLR_PRIMARY};
    secondary: ${CLR_SECONDARY};
    accent:    ${CLR_ACCENT};
    muted:     ${CLR_MUTED};
    border:    ${CLR_BORDER};
    success:   ${CLR_SUCCESS};
    warning:   ${CLR_WARNING};
    error:     ${CLR_ERROR};

	font-mono: "${FONT_ROFI_MONO}";
	font-search: "${FONT_ROFI_SEARCH}";
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

    property color background: "${CLR_QML_BG}"
    property color backgroundAlt: "${CLR_QML_BG_ALT}"
    property color primary: "${CLR_PRIMARY}"
    property color textPrimary: "${CLR_FG}"
    property color textSecondary: "${CLR_FG_MUTED}"
    property color textMuted: "${CLR_TEXT_MUTED}"
	property color todayText: "${CLR_ACCENT}"
	property color bbyBlue: "${CLR_BBYBLUE}"
	property string fontCalendar: "${FONT_CALENDAR}"
}
EOF



echo "Themes generated!"
