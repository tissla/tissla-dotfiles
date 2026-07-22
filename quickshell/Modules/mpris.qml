import ".."
import QtQuick
import Quickshell.Services.Mpris

BaseModule {
    id: mprisModule

    readonly property list<MprisPlayer> availablePlayers: Mpris.players.values
    property MprisPlayer player: availablePlayers.find(p => p.isPlaying) ?? availablePlayers.find(p => p.canControl && p.canPlay) ?? null

    moduleIcon: {
        if (!player)
            return "⏸";

        if (player.playbackState === MprisPlaybackState.Playing)
            return "▶";

        if (player.playbackState === MprisPlaybackState.Paused)
            return "⏸";

        return "⏹";
    }
    moduleText: {
        if (!player)
            return "No media";

        let title = player.trackTitle || "Unknown";
        let artist = player.trackArtist || "";
        if (artist && title)
            return artist + " - " + title;

        return title;
    }

    clip: true


    onRightClickCallback: () => {
        mprisModule.player.togglePlaying();
    }
}
