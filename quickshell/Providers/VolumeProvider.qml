pragma Singleton
import ".."
import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var outputs: Pipewire.nodes.values.filter(node => node.audio && !node.isStream && node.isSink)
    readonly property var inputs: Pipewire.nodes.values.filter(node => node.audio && !node.isStream && !node.isSink)
    readonly property int volume: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool isMuted: sink && sink.audio ? sink.audio.muted : false

    // Track device parameters so sliders and mute indicators also follow external changes.
    property PwObjectTracker tracker: PwObjectTracker {
        objects: root.outputs.concat(root.inputs)
    }

    function deviceName(node) {
        return node ? (node.description || node.nickname || node.name || "Audio device") : "No audio device";
    }

    function setNodeVolume(node, percent) {
        if (!node || !node.ready || !node.audio || !Number.isFinite(percent))
            return;
        node.audio.volume = Math.max(0, Math.min(100, percent)) / 100;
        if (node.isSink)
            node.audio.muted = false;
    }

    function toggleNodeMute(node) {
        if (node && node.ready && node.audio)
            node.audio.muted = !node.audio.muted;
    }

    function selectDefault(node) {
        if (!node || !node.ready)
            return;
        if (outputs.indexOf(node) !== -1)
            Pipewire.preferredDefaultAudioSink = node;
        else if (inputs.indexOf(node) !== -1)
            Pipewire.preferredDefaultAudioSource = node;
    }

    // Bar scrolling and right-click retain their existing default-output controls.
    function setVolume(percent) {
        setNodeVolume(sink, percent);
        if (sink && sink.ready)
            PlaySoundService.playSound("volume-change");
    }

    function toggleMute() {
        toggleNodeMute(sink);
        if (sink && sink.ready)
            PlaySoundService.playSound("volume-change");
    }
}
