// GlobalMouse.qml
import QtQuick
import Quickshell.Io
pragma Singleton

Process {
    id: globalMouse

    property point pos: Qt.point(0, 0)
    property var _pendingCallback: null

    // callback "smooth" check
    function requestPosition(cb) {
        _pendingCallback = cb;
        command = ["hyprctl", "-j", "cursorpos"];
        running = true;
    }

    stdout: StdioCollector {
        onStreamFinished: {
            const obj = JSON.parse(text);
            pos = Qt.point(obj.x, obj.y);
            if (globalMouse._pendingCallback) {
                const cb = globalMouse._pendingCallback;
                globalMouse._pendingCallback = null;
                cb(globalMouse.pos);
            }
        }
    }

}
