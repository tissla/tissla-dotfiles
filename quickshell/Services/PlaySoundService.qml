import QtQuick
pragma Singleton

QtObject {
    id: root

    property Timer throttleTimer
    property bool noPlay: false
    property var map: ({
        "login": "/usr/share/sounds/freedesktop/stereo/service-login.oga",
        "logout": "/usr/share/sounds/freedesktop/stereo/service-logout.oga",
        "bell": "/usr/share/sounds/freedesktop/stereo/bell.oga",
        "volume-change": "/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga",
        "error": "/usr/share/sounds/freedesktop/stereo/dialog-error.oga",
        "message": "/usr/share/sounds/freedesktop/stereo/message.oga"
    })

    function runCommand(cmdArray) {
        var process = Qt.createQmlObject('import Quickshell.Io; Process { running: true }', root);
        process.command = cmdArray;
    }

    function playSound(key) {
        if (!noPlay) {
            let sound = map[key];
            runCommand(["pw-play", sound]);
            noPlay = true;
            throttleTimer.start();
        }
    }

    throttleTimer: Timer {
        interval: 100
        repeat: false
        onTriggered: {
            root.noPlay = false;
        }
    }

}
