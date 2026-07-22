import QtQuick
import Quickshell
pragma Singleton

// Detects the running Wayland compositor from environment variables set by
// each compositor itself, so the rest of the shell never has to guess.
QtObject {
    id: compositor

    readonly property string hyprlandSignature: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || ""
    readonly property string niriSocket: Quickshell.env("NIRI_SOCKET") || ""
    readonly property bool isHyprland: hyprlandSignature.length > 0
    readonly property bool isNiri: !isHyprland && niriSocket.length > 0
    readonly property string current: isHyprland ? "hyprland" : (isNiri ? "niri" : "unknown")

    Component.onCompleted: console.log("[Compositor] Detected:", current)
}
