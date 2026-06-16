import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    id: root

    property Timer throttleTimer
    property bool noPlay: false
    // TODO: move sound files to local assets, find and use new sound files
    property var map: ({
        "login": "/usr/share/sounds/freedesktop/stereo/service-login.oga",
        "logout": "/usr/share/sounds/freedesktop/stereo/service-logout.oga",
        "bell": "/usr/share/sounds/freedesktop/stereo/bell.oga",
        "volume-change": "/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga",
        "error": "/usr/share/sounds/freedesktop/stereo/dialog-error.oga",
        "message": "/usr/share/sounds/freedesktop/stereo/message.oga"
    })
    property Process soundProcess

    function playSound(key) {
        if (!noPlay) {
            let sound = map[key];
            soundProcess.command = ["paplay", sound];
            soundProcess.running = true;
            noPlay = true;
            if (!throttleTimer.running)
                throttleTimer.start();

        }
    }

    soundProcess: Process {
        running: false
    }

    throttleTimer: Timer {
        interval: 100
        repeat: false
        onTriggered: {
            root.noPlay = false;
        }
    }

}
