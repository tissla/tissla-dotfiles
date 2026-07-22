import ".."
import QtQuick
import Quickshell.Io
pragma Singleton

// Niri backend for WorkspaceProvider. Talks directly to niri's own IPC
// socket ($NIRI_SOCKET, see https://niri-wm.github.io/niri/IPC.html) since
// Quickshell has no dedicated Quickshell.Niri module. Normalizes niri's
// Workspace shape into the same { id, idx, monitor, active, special } shape
// HyprlandWorkspaceProvider produces. Niri has no scratchpad/special-
// workspace concept, so `special` is always false here.
QtObject {
    id: provider

    property var rawWorkspaces: []
    property Socket eventSocket
    property Socket actionSocket

    readonly property var workspaces: rawWorkspaces.map((ws) => ({
                "id": ws.id,
                "idx": ws.idx,
                "monitor": ws.output || "",
                "active": !!ws.is_focused,
                "special": false
            }))

    function applyEvent(ev) {
        if (ev.WorkspacesChanged) {
            rawWorkspaces = ev.WorkspacesChanged.workspaces;
            return ;
        }
        if (ev.WorkspaceActivated) {
            const targetId = ev.WorkspaceActivated.id;
            const focused = !!ev.WorkspaceActivated.focused;
            const target = rawWorkspaces.find((ws) => ws.id === targetId);
            const targetOutput = target ? target.output : null;
            rawWorkspaces = rawWorkspaces.map((ws) => {
                const isTarget = ws.id === targetId;
                return Object.assign({
                }, ws, {
                    "is_active": isTarget ? true : (ws.output === targetOutput ? false : ws.is_active),
                    "is_focused": isTarget ? focused : (focused ? false : ws.is_focused)
                });
            });
            return ;
        }
        if (ev.WorkspaceUrgencyChanged) {
            const targetId = ev.WorkspaceUrgencyChanged.id;
            const urgent = !!ev.WorkspaceUrgencyChanged.urgent;
            rawWorkspaces = rawWorkspaces.map((ws) => ws.id === targetId ? Object.assign({
            }, ws, {
                "is_urgent": urgent
            }) : ws);
            return ;
        }
    }

    // one-shot request/response socket used for dispatching actions
    function activate(id) {
        actionSocket.pendingRequest = JSON.stringify({
            "Action": {
                "FocusWorkspace": {
                    "reference": {
                        "Id": id
                    }
                }
            }
        });
        actionSocket.connected = true;
    }

    // persistent connection that streams niri's current state, then live updates
    eventSocket: Socket {
        path: Compositor.niriSocket
        connected: Compositor.isNiri

        parser: SplitParser {
            onRead: (line) => {
                if (!line)
                    return ;

                let msg;
                try {
                    msg = JSON.parse(line);
                } catch (e) {
                    return ;
                }
                provider.applyEvent(msg);
            }
        }

        onConnectionStateChanged: {
            if (connected) {
                write("\"EventStream\"\n");
                flush();
            }
        }
    }

    actionSocket: Socket {
        property string pendingRequest: ""

        path: Compositor.niriSocket

        parser: SplitParser {
            onRead: (line) => {
                actionSocket.connected = false;
            }
        }

        onConnectionStateChanged: {
            if (connected && pendingRequest !== "") {
                write(pendingRequest + "\n");
                flush();
                pendingRequest = "";
            }
        }
    }

}
