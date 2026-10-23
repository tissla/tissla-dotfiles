import ".."
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Scope {
    id: root
    property bool active: false
    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property bool authPending: false
    property bool capsLock: false
    property string failureMessage: ""
    signal unlocked

    function reset() {
        if (pam.active)
            pam.abort();
        currentText = "";
        unlockInProgress = false;
        authPending = false;
        showFailure = false;
        failureMessage = "";
    }
    function fail(message) {
        authPending = false;
        unlockInProgress = false;
        if (pam.active)
            pam.abort();
        currentText = "";
        failureMessage = message;
        showFailure = true;
        PlaySoundService.playSound("error");
    }
    function tryUnlock() {
        if (!active || currentText === "" || unlockInProgress)
            return;
        showFailure = false;
        authPending = true;
        unlockInProgress = true;
        if (!pam.start())
            fail("Authentication unavailable");
    }
    function refreshCapsLock() {
        if (active && Compositor.isHyprland && !keyboardQuery.running)
            keyboardQuery.running = true;
    }
    onActiveChanged: {
        reset();
        if (active)
            refreshCapsLock();
    }
    onCurrentTextChanged: showFailure = false

    Timer {
        interval: 2000
        running: root.active && Compositor.isHyprland
        repeat: true
        onTriggered: root.refreshCapsLock()
    }
    Process {
        id: keyboardQuery
        command: ["hyprctl", "-j", "devices"]
        stdout: StdioCollector {
            id: keyboardOutput
        }
        onExited: (code, status) => {
            if (code !== 0 || status !== 0 || !root.active)
                return;
            try {
                const keyboards = JSON.parse(keyboardOutput.text).keyboards || [];
                const keyboard = keyboards.find(k => k.main) || keyboards[0];
                if (keyboard && typeof keyboard.capsLock === "boolean")
                    root.capsLock = keyboard.capsLock;
            } catch (error) {
                // Keep the last known state if Hyprland is temporarily unavailable.
            }
        }
    }
    PamContext {
        id: pam
        configDirectory: "pam"
        config: "password.conf"
        onPamMessage: {
            if (responseRequired && root.active && root.unlockInProgress)
                respond(root.currentText);
        }
        onError: {
            if (root.active && root.unlockInProgress)
                root.fail("Authentication unavailable");
        }
        onCompleted: result => {
            // Ignore callbacks from a cancelled/previous lock session.
            if (!root.active || !root.unlockInProgress)
                return;
            if (result === PamResult.Success) {
                root.currentText = "";
                root.authPending = false;
                root.unlockInProgress = false;
                root.unlocked();
                PlaySoundService.playSound("login");
            } else {
                root.fail(result === PamResult.Failed ? "Incorrect password" : result === PamResult.MaxTries ? "Too many attempts. Try again shortly." : "Authentication unavailable");
            }
        }
    }
}
