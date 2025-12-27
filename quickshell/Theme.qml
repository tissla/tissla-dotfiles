import QtQuick
pragma Singleton

QtObject {
    id: theme

    property color background: "#CC1e1b29"
    property color backgroundSolid: "#1e1b29"
    property color backgroundAlt: "#E62b263b"
    property color backgroundAltSolid: "#342e4a"
    property color primary: "#8b5cf6"
    property color foreground: "#c9c7d4"
    property color foregroundAlt: "#9ca3af"
    property color inactive: "#4b5564"
    property color accent: "#ff9e64"
    property color info: "#559cd6"
    property color surface: "#41395e"
    property color active: "#76b900"
    property int radius: 20
    property int radiusAlt: 4
    property string noteDirectory: "/home/tissla/Documents/Todo"
    property string fontMain: "JetBrains Nerd Font"
    property string fontMono: "JetBrainsMono Nerd Font"
}
