import ".."
import QtQuick
import Quickshell.Hyprland
pragma Singleton

// Hyprland backend for WorkspaceProvider. Normalizes Hyprland's IPC model
// (including its quirks, like the -98 placeholder workspace and per-monitor
// special/scratchpad workspaces) into the shape WorkspaceProvider expects:
// { id, idx, monitor, active, special }.
QtObject {
    id: provider

    property Connections hyprlandEvents

    readonly property var workspaces: {
        const focused = Hyprland.focusedWorkspace;
        const focusedId = focused ? focused.id : null;
        const result = [];
        for (const ws of Hyprland.workspaces.values) {
            if (ws.id === -98)
                continue;

            const monitorName = ws.monitor ? ws.monitor.name : "";
            const isActive = ws.id === focusedId;
            result.push({
                id: ws.id,
                idx: ws.id,
                monitor: monitorName,
                active: isActive,
                special: isActive && hasOpenSpecial(monitorName)
            });
        }
        return result;
    }

    function hasOpenSpecial(monitorName) {
        for (const m of Hyprland.monitors.values) {
            if (m.name !== monitorName)
                continue;

            const sw = m.lastIpcObject ? m.lastIpcObject.specialWorkspace : null;
            return !!(sw && sw.name);
        }
        return false;
    }

    function activate(id) {
        // fix for lua, go back to workspace.activate() once quickshell updates
        Hyprland.dispatch(`hl.dsp.focus({ workspace = "${id}" })`);
    }

    hyprlandEvents: Connections {
        target: Hyprland
        function onRawEvent(ev) {
            if (ev.name === "activespecial" || ev.name === "focusedmon")
                Hyprland.refreshMonitors();

        }
    }

}
