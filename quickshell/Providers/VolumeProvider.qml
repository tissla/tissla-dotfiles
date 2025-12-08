
import QtQuick
import Quickshell.Services.Pipewire
pragma Singleton

QtObject {
    id: volumeData

    // --- Samma publika API som innan ---
    property int volume: 50      // 0–100
    property bool isMuted: false

    // Alltid aktuella default-sink från PipeWire
    property var sink: Pipewire.defaultAudioSink

    property Connections connection
	property PwObjectTracker tracker 


	tracker: PwObjectTracker {
        objects: sink ? [sink] : []
    }

    // --- Publika funktioner ---

    function refresh() {
        if (!sink || !sink.audio)
            return;

        volume = Math.round(sink.audio.volume * 100);
        isMuted = sink.audio.muted;
    }

    function setVolume(newVolume) {
        if (!sink || !sink.audio)
            return;

        newVolume = Math.max(0, Math.min(100, newVolume));

        // typiskt beteende: ändrar volym → auto-unmute
        sink.audio.muted = false;
        sink.audio.volume = newVolume / 100.0;

        // spegla direkt i vår egen state
        volume = newVolume;
        isMuted = false;
    }

    function toggleMute() {
        if (!sink || !sink.audio)
            return;

        sink.audio.muted = !sink.audio.muted;
        isMuted = sink.audio.muted;
    }

    // När default-sink byts (nyt ljudkort/hdmi osv) → uppdatera
    onSinkChanged: refresh()

    // Håll i sync när något annat program ändrar volym/mute
    connection: Connections {
        // samma stil som officiella volume-osd-exemplet
        target: Pipewire.defaultAudioSink?.audio

        function onVolumeChanged() {
            volumeData.refresh();
        }

        function onMutedChanged() {
            volumeData.refresh();
        }
    }

    Component.onCompleted: refresh()
}
