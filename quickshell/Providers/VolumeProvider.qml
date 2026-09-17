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
    readonly property var playbackStreams: Pipewire.nodes.values.filter(node => node.audio && node.type === PwNodeType.AudioOutStream)
    readonly property int volume: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool isMuted: sink && sink.audio ? sink.audio.muted : false

    // Bind streams too, so their metadata and audio controls stay up to date.
    property PwObjectTracker tracker: PwObjectTracker {
        objects: root.outputs.concat(root.inputs, root.playbackStreams)
    }

    function deviceName(node) {
        return node ? (node.description || node.nickname || node.name || "Audio device") : "No audio device";
    }

    function streamName(node) {
        const properties = node && node.ready ? node.properties : {};
        return properties["application.name"] || deviceName(node);
    }

    function streamDescription(node) {
        const properties = node && node.ready ? node.properties : {};
        const media = properties["media.name"] || "";
        return media !== streamName(node) ? media : "";
    }

    function setNodeVolume(node, percent) {
        if (!node || !node.ready || !node.audio || !Number.isFinite(percent))
            return;
        node.audio.volume = Math.max(0, Math.min(100, percent)) / 100;
        // Quickshell marks both playback streams and output devices as sinks.
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
