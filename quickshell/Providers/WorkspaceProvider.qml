import ".."
import QtQuick
pragma Singleton

// Compositor-agnostic facade over the workspace backends. This is the only
// workspace API modules should talk to — no module should import
// Quickshell.Hyprland or talk to niri's IPC directly.
QtObject {
    id: provider

    readonly property QtObject backend: Compositor.isNiri ? NiriWorkspaceProvider : HyprlandWorkspaceProvider
    readonly property var workspaces: backend ? backend.workspaces : []

    function activate(id) {
        if (backend)
            backend.activate(id);

    }

}
