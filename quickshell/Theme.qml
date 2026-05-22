import QtQuick
pragma Singleton

QtObject {
    id: theme

    // SEMANTIC COLORS
    property color accent:  "#8b5cf6"
    property color warning: "#ff9e64"
    property color success: "#76b900"
    property color info:    "#d4abf8"
    property color muted:   "#7a82ab"

    // BACKGROUND LAYERS
    property color base:         "#CC1e1b29"
    property color baseSolid:    "#1e1b29"
    property color mantle:       "#E61d1a29"
    property color mantleSolid:  "#1d1a29"

    // TEXT
    property color text:     "#c9c7d4"
    property color subtext1: "#9ca3af"

    // SURFACES
    property color surface0: "#2b263b"
    property color surface1: "#342e4a"
    property color surface2: "#58498d"

    // OVERLAYS
    property color overlay0: "#4a436b"
    property color overlay1: "#7a82ab"

    // FULL PALETTE
    property color mauve:    "#8b5cf6"
    property color lavender: "#d4abf8"
    property color peach:    "#ff9e64"
    property color green:    "#76b900"
    property color red:      "#f87171"
    property color yellow:   "#fbbf24"
    property color blue:     "#569cd6"
    property color teal:     "#22d3ee"
    property color pink:     "#c084fc"
    property color white:    "#f9fafb"
    property color black:    "#0d0b13"

    // ROUNDING
    property int radius:    20
    property int radiusAlt: 8

    // FONTS
    property string fontMain: "Noto Sans"
    property string fontMono: "JetBrainsMono Nerd Font"

    // SIZES AND GAPS
    property int borderWidth: 3
    property int gap:         20

    // SPACINGS
    property int spacingXs: 4
    property int spacingSm: 8
    property int spacingMd: 12
    property int spacingLg: 20
    property int spacingXl: 30

    // MODULE DIMENSIONS
    property int moduleWidth:  40
    property int moduleHeight: SettingsManager.barHeight < 40 ? SettingsManager.barHeight : 40

    // FONT SIZES
    property int fontSizeHuge:  200
    property int fontSizeXxl:   48
    property int fontSizeXl:    20
    property int fontSizeLg:    18
    property int fontSizeMd:    16
    property int fontSizeBase:  15
    property int fontSizeSm:    14
    property int fontSizeXs:    13
    property int fontSizeXxs:   12
    property int fontSizeTiny:  11
    property int fontSizeMicro: 10
}
