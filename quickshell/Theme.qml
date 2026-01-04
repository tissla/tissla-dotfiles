import QtQuick
pragma Singleton

QtObject {
    id: theme
    
    // COLORS
    property color background: "#CC1e1b29"
    property color backgroundSolid: "#1e1b29"
    property color backgroundAlt: "#E61d1a29"
    property color backgroundAltSolid: "#1d1a29"
    property color primary: "#8b5cf6"
    property color foreground: "#c9c7d4"
    property color foregroundAlt: "#9ca3af"
    property color inactive: "#7a82ab"
    property color accent: "#ff9e64"
    property color info: "#d4abf8"
    property color surface: "#58498d"
    property color active: "#76b900"
    
    // ROUNDING
    property int radius: 20
    property int radiusAlt: 8
    
    // FONTS
    property string fontMain: "JetBrains Nerd Font"
    property string fontMono: "JetBrainsMono Nerd Font"
    
    // SIZES AND GAPS
    property int borderWidth: 3
    property int gap: 20
    
    // SPACINGS
    property int spacingXs: 4
    property int spacingSm: 8
    property int spacingMd: 12
    property int spacingLg: 20
    property int spacingXl: 30
    
    // Module dimensions
    property int moduleWidth: 40
    property int moduleHeight: SettingsManager.barHeight < 40 ? SettingsManager.barHeight : 40
    
    // Font sizes
    property int fontSizeHuge: 200
    property int fontSizeXxl: 48
    property int fontSizeXl: 20
    property int fontSizeLg: 18
    property int fontSizeMd: 16
    property int fontSizeBase: 15
    property int fontSizeSm: 14
    property int fontSizeXs: 13
    property int fontSizeXxs: 12
    property int fontSizeTiny: 11
    property int fontSizeMicro: 10
}
