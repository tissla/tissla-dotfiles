import QtQuick
import Quickshell.Services.Pipewire
pragma Singleton

QtObject {
    id: volumeData

    property int volume: 50
    property bool isMuted: false
    property var sink: Pipewire.defaultAudioSink || null
    property Connections connection
    property PwObjectTracker tracker

    function refresh() {
        if (!sink || !sink.audio)
            return ;

        volume = Math.round(sink.audio.volume * 100);
        isMuted = sink.audio.muted;
    }

    function setVolume(newVolume) {
        if (!sink || !sink.audio)
            return ;

        newVolume = Math.max(0, Math.min(100, newVolume));
        sink.audio.muted = false;
        sink.audio.volume = newVolume / 100;
        volume = newVolume;
        isMuted = false;
    }

    function toggleMute() {
        if (!sink || !sink.audio)
            return ;

        sink.audio.muted = !sink.audio.muted;
        isMuted = sink.audio.muted;
    }

    onSinkChanged: refresh()
    Component.onCompleted: refresh()

    tracker: PwObjectTracker {
        objects: sink ? [sink] : []
    }

    connection: Connections {
        function onVolumeChanged() {
            volumeData.refresh();
        }

        target: (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) ? Pipewire.defaultAudioSink.audio : null
    }

}
