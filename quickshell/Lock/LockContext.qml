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

    signal unlocked()

    function tryUnlock() {
        if (currentText === "")
            return ;

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
            if (result === PamResult.Success) {
                RunCommandService.playSound("/usr/share/sounds/freedesktop/stereo/service-login.oga");
                root.unlocked();
            } else {
                RunCommandService.playSound("/usr/share/sounds/freedesktop/stereo/dialog-error.oga");
                root.currentText = "";
                root.showFailure = true;
            }
            root.unlockInProgress = false;
        }
    }

}
