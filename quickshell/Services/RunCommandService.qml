import QtQuick
pragma Singleton

// todo: rename to just playsound service
QtObject {
    id: root

    function runCommand(cmdArray) {
        var process = Qt.createQmlObject('import Quickshell.Io; Process { running: true }', root);
        process.command = cmdArray;
    }

    function playSound(soundFile) {
        runCommand(["pw-play", soundFile]);
    }

}
