import ".."
// LockContext.qml
import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property bool authPending: false

    signal unlocked()

    function tryUnlock() {
        if (currentText === "" || unlockInProgress)
            return ;

        showFailure = false;
        authPending = true;
        unlockInProgress = true;
        pam.start();
    }

    onCurrentTextChanged: showFailure = false

    PamContext {
        id: pam

        configDirectory: "pam"
        config: "password.conf"
        onPamMessage: {
            if (this.responseRequired)
                this.respond(root.currentText);

        }
        onCompleted: (result) => {
            root.authPending = false;
            if (result === PamResult.Success) {
                root.unlocked();
                PlaySoundService.playSound("login");
            } else {
                root.currentText = "";
                root.showFailure = true;
                PlaySoundService.playSound("error");
            }
            root.unlockInProgress = false;
        }
    }

}
