import QtQuick
pragma Singleton

QtObject {
    id: theme

    property color background: "#CC1e1b29"
	property color backgroundSolid: "#1e1b29"
    property color backgroundAlt: "#E62b263b"
	property color backgroundAltSolid: "#342e4a"
    property color primary: "#8b5cf6"
    property color textPrimary: "#c9c7d4"
    property color textSecondary: "#9ca3af"
    property color textMuted: "#4b5564"
	property color todayText: "#a78bfa"
	property color bbyBlue: "#5fafd7"
	property color accent: "#ff9e64"
	property color fillClr: "#41395e"
	property color green: "#76b900"
	property string fontMain: "Rubik SemiBold"
	property string fontMono: "JetBrains Nerd Font"
}
