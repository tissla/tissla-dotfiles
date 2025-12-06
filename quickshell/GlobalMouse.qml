// GlobalMouse.qml
import QtQuick
import Quickshell.Io
pragma Singleton

Process {
    id: globalMouse

    property var pos: ({
        "x": 0,
        "y": 0
    })
    property var _pendingCallback: null

    function requestPosition(cb) {
        _pendingCallback = cb;
        command = ["hyprctl", "-j", "cursorpos"];
        running = true;
    }

    stdout: StdioCollector {
        onStreamFinished: {
            try {
                const obj = JSON.parse(text);
                globalMouse.pos = ({
                    "x": obj.x,
                    "y": obj.y
                });
                if (globalMouse._pendingCallback) {
                    const cb = globalMouse._pendingCallback;
                    globalMouse._pendingCallback = null;
                    cb(globalMouse.pos);
                }
            } catch (e) {
                console.error("[GlobalMouse] Failed to parse cursorpos:", e, text);
                if (globalMouse._pendingCallback) {
                    const cb = globalMouse._pendingCallback;
                    globalMouse._pendingCallback = null;
                    cb({
                        "x": 0,
                        "y": 0
                    });
                }
            }
        }
    }

}
