import "../.."
import QtQuick
import Quickshell.Services.Mpris

Item {
    id: mprisModule

	property var screen: null

	readonly property list<MprisPlayer> availablePlayers: Mpris.players.values
    property MprisPlayer player: availablePlayers.find(p => p.isPlaying) ?? availablePlayers.find(p => p.canControl && p.canPlay) ?? null


    property string moduleIcon: {
        if (!player)
            return "⏸";

        if (player.playbackState === MprisPlaybackState.Playing)
            return "▶";

        if (player.playbackState === MprisPlaybackState.Paused)
            return "⏸";

        return "⏹";
    }
    property string moduleText: {
        if (!player)
            return "No media";

        let title = player.trackTitle || "Unknown";
        let artist = player.trackArtist || "";
        if (artist && title)
            return artist + " - " + title;

        return title;
    }

    width: Math.min(mprisRow.width + 16, 400)
    height: 40

	Row {
        id: mprisRow

        anchors.centerIn: parent
        spacing: 8

        Text {
            text: mprisModule.moduleIcon
            font.pixelSize: 20
            color: Theme.primary
			anchors.verticalCenter: parent.verticalCenter
			font.weight: Font.Bold
        }

        Text {
            text: mprisModule.moduleText
            font.family: Theme.fontMain
			font.pixelSize: 15
			font.weight: Font.Bold
            color: Theme.foregroundAlt
            elide: Text.ElideRight
            maximumLineCount: 1
            anchors.verticalCenter: parent.verticalCenter
        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (!mprisModule.player)
                return ;

            if (mouse.button === Qt.RightButton && mprisModule.player.canGoNext)
                mprisModule.player.next();
            else if (mouse.button === Qt.LeftButton && mprisModule.player.canTogglePlaying)
                mprisModule.player.togglePlaying();
        }
    }

}
