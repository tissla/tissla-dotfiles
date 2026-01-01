#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/Dotfiles"
THEMES_JSON="$DOTFILES/themes/themes.json"
ACTIVE_THEME="$1"
if [[ "$ACTIVE_THEME" == "null" || -z "$ACTIVE_THEME" ]]; then
    echo "Error: No theme specified"
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "Error: jq is not installed"
    exit 1
fi

if [[ ! -f "$THEMES_JSON" ]]; then
    echo "Error: $THEMES_JSON not found"
    exit 1
fi

# Helper functions
get_color() {
    jq -r ".themes[] | select(.id == \"$ACTIVE_THEME\") | .colors.$1" "$THEMES_JSON"
}

get_font() {
    jq -r ".themes[] | select(.id == \"$ACTIVE_THEME\") | .fonts.$1" "$THEMES_JSON"
}

get_value() {
    jq -r ".themes[] | select(.id == \"$ACTIVE_THEME\") | .values.$1" "$THEMES_JSON"
}

get_path() {
    local path=$(jq -r ".themes[] | select(.id == \"$ACTIVE_THEME\") | .paths.$1" "$THEMES_JSON")
    echo "${path//\$HOME/$HOME}"
}

get_spacing() {
    jq -r ".themes[] | select(.id == \"$ACTIVE_THEME\") | .spacing.$1" "$THEMES_JSON"
}

get_fontsize() {
    jq -r ".themes[] | select(.id == \"$ACTIVE_THEME\") | .fontSizes.$1" "$THEMES_JSON"
}

strip_hash() {
    echo "${1#\#}"
}

mkdir -p "$HOME/.config/quickshell"
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.config/rofi"
mkdir -p "$HOME/.config/alacritty"

# Generate Theme.qml
cat >"$HOME/.config/quickshell/Theme.qml" <<EOF
import QtQuick
import Quickshell
pragma Singleton

QtObject {
    id: theme
    
    // COLORS
    property color background: "#CC$(strip_hash "$(get_color background)")"
    property color backgroundSolid: "$(get_color background)"
    property color backgroundAlt: "#E6$(strip_hash "$(get_color primaryMuted)")"
    property color backgroundAltSolid: "$(get_color muted)"
    property color primary: "$(get_color primary)"
    property color foreground: "$(get_color foreground)"
    property color foregroundAlt: "$(get_color foregroundMuted)"
    property color inactive: "$(get_color inactive)"
    property color accent: "$(get_color accent)"
    property color info: "$(get_color info)"
    property color surface: "$(get_color surface)"
    property color active: "$(get_color active)"
    
    // ROUNDING
    property int radius: $(get_value radius)
    property int radiusAlt: $(get_value radiusAlt)
    
    // FONTS
    property string fontMain: "$(get_font main)"
    property string fontMono: "$(get_font mono)"
    
    // PATHS
    property string noteDirectory: "$(get_path noteDirectory)"
    
    // SIZES AND GAPS
    property int borderWidth: $(get_value borderWidth)
    property int gap: $(get_value gap)
    
    // SPACINGS
    property int spacingXs: $(get_spacing xs)
    property int spacingSm: $(get_spacing sm)
    property int spacingMd: $(get_spacing md)
    property int spacingLg: $(get_spacing lg)
    property int spacingXl: $(get_spacing xl)
    
    // Module dimensions
    property int moduleWidth: 40
    property int moduleHeight: SettingsManager.barHeight < 40 ? SettingsManager.barHeight : 40
    
    // Font sizes
    property int fontSizeHuge: $(get_fontsize huge)
    property int fontSizeXxl: $(get_fontsize xxl)
    property int fontSizeXl: $(get_fontsize xl)
    property int fontSizeLg: $(get_fontsize lg)
    property int fontSizeMd: $(get_fontsize md)
    property int fontSizeBase: $(get_fontsize base)
    property int fontSizeSm: $(get_fontsize sm)
    property int fontSizeXs: $(get_fontsize xs)
    property int fontSizeXxs: $(get_fontsize xxs)
    property int fontSizeTiny: $(get_fontsize tiny)
    property int fontSizeMicro: $(get_fontsize micro)
}
EOF

# Generate Hyprland theme
cat >"$HOME/.config/theme/theme.conf" <<EOF
\$bg        = rgb($(strip_hash "$(get_color background)"))
\$fg        = rgb($(strip_hash "$(get_color foreground)"))
\$primary   = rgb($(strip_hash "$(get_color primary)"))
\$secondary = rgb($(strip_hash "$(get_color primaryMuted)"))
\$bgalpha   = 0xee$(strip_hash "$(get_color background)")
\$mutedalpha = 0xaa$(strip_hash "$(get_color muted)")
EOF

# Generate Rofi theme
cat >"$HOME/.config/theme/theme.rasi" <<EOF
* {
    bg:        $(get_color background)E6;
    bg-alt:    $(get_color backgroundDark)E6;
    fg:        $(get_color foreground);
    primary:   $(get_color primary);
    secondary: $(get_color secondary);
    muted:     $(get_color muted);
    font-mono: "$(get_font main) $(get_font style | sed 's/.*/\u&/') $(get_font size)";
}
EOF

# Generate Alacritty theme
cat >"$HOME/.config/theme/theme.toml" <<EOF
[colors.primary]
background = "0x$(strip_hash "$(get_color background)")"
foreground = "0x$(strip_hash "$(get_color foreground)")"

[colors.normal]
black   = "0x$(strip_hash "$(get_color background)")"
red     = "0xf87171"
green   = "0x34d399"
yellow  = "0xfbbf24"
blue    = "0x1e3a8a"
magenta = "0x$(strip_hash "$(get_color primary)")"
cyan    = "0x22d3ee"
white   = "0xf9fafb"

[colors.bright]
black   = "0x$(strip_hash "$(get_color primaryMuted)")"
red     = "0xf87171"
green   = "0x34d399"
yellow  = "0xfbbf24"
blue    = "0x374151"
magenta = "0xa78bfa"
cyan    = "0x7dd3fc"
white   = "0xffffff"

[font.normal]
family = "$(get_font mono)"
style = "$(get_font style | sed 's/.*/\u&/')"
EOF

echo "✓ Generated theme: $ACTIVE_THEME"
