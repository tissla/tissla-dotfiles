import QtQuick
pragma Singleton

QtObject {
    id: theme

    property color background: "#CC1e1b29"
    property color backgroundAlt: "#CC2b263b"
    property color primary: "#8b5cf6"
    property color textPrimary: "#c9c7d4"
    property color textSecondary: "#9ca3af"
    property color textMuted: "#4b5564"
	property color todayText: "#facc15"

	property string fontCalendar: "JetBrains Nerd Font"
}
