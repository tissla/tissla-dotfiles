import QtQuick
import Quickshell
pragma Singleton

QtObject {
    id: theme
    
    // COLORS
    property color background: "#CC1d3149"
    property color backgroundSolid: "#1d3149"
    property color backgroundAlt: "#E60f2c53"
    property color backgroundAltSolid: "#285272"
    property color primary: "#559cd6"
    property color foreground: "#c9c7d4"
    property color foregroundAlt: "#9ca3af"
    property color inactive: "#1e394e"
    property color accent: "#ff9e64"
    property color info: "#559cd6"
    property color surface: "#457fae"
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
