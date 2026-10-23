import ".."
import QtQuick
import Quickshell

FocusScope {
    id: root
    required property var context
    required property var screen
    required property var scene
    readonly property bool showHud: screen !== null && screen.name === scene.primaryName
    property bool promptRequested: false
    readonly property bool promptVisible: promptRequested || context.currentText.length > 0 || context.authPending || context.showFailure || context.capsLock
    focus: true
    clip: true

    Starfield {
        objectName: "starfield"
        anchors.fill: parent
        scene: root.scene
        screen: root.screen
    }

    // Each native lock surface can receive keyboard focus. Only the primary
    // surface renders feedback, but the first key works on every monitor.
    TextInput {
        id: input
        objectName: "lockInput"
        width: 1
        height: 1
        opacity: 0
        focus: true
        readOnly: root.context.unlockInProgress
        echoMode: TextInput.Password
        passwordMaskDelay: 0
        maximumLength: 256
        cursorVisible: false
        text: root.context.currentText
        Accessible.ignored: !root.showHud
        onTextChanged: {
            if (!root.context.unlockInProgress && root.context.currentText !== text)
                root.context.currentText = text;
        }
        onAccepted: root.context.tryUnlock()
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                if (!root.context.unlockInProgress) {
                    root.context.currentText = "";
                    root.context.showFailure = false;
                    root.promptRequested = false;
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_CapsLock && !event.isAutoRepeat) {
                root.context.capsLock = !root.context.capsLock;
                root.context.refreshCapsLock();
            }
        }
        Connections {
            target: root.context
            function onCurrentTextChanged() {
                if (input.text !== root.context.currentText)
                    input.text = root.context.currentText;
            }
            function onShowFailureChanged() {
                if (root.context.showFailure)
                    failureShake.restart();
            }
        }
    }
    TapHandler {
        onTapped: {
            input.forceActiveFocus();
            root.promptRequested = true;
            promptTimeout.restart();
        }
    }
    Timer {
        id: promptTimeout
        interval: 5000
        onTriggered: root.promptRequested = false
    }

    Column {
        id: hud
        objectName: "lockHud"
        visible: root.showHud
        width: Math.min(420, root.width - 48)
        anchors.centerIn: parent
        spacing: 10

        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }
        Text {
            objectName: "lockClock"
            width: parent.width
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.text
            font.family: Theme.fontMain
            font.pixelSize: Math.min(96, root.width * 0.12)
            font.weight: Font.Light
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            width: parent.width
            text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
            color: Theme.subtext1
            font.family: Theme.fontMain
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
        }
        Item {
            width: 1
            height: 22
        }
        Rectangle {
            id: passwordBox
            property real shake: 0
            width: parent.width
            height: 54
            color: Qt.alpha(Theme.surface0, 0.85)
            radius: 12
            border.width: 1
            border.color: root.context.showFailure ? Theme.red : Theme.accent
            opacity: root.promptVisible ? 1 : 0
            transform: Translate {
                x: passwordBox.shake
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
            Text {
                objectName: "passwordDots"
                anchors.centerIn: parent
                text: "●".repeat(Math.min(root.context.currentText.length, 28))
                color: Theme.text
                font.pixelSize: 16
                font.letterSpacing: 4
                textFormat: Text.PlainText
            }
            NumberAnimation {
                id: failureShake
                target: passwordBox
                property: "shake"
                from: -8
                to: 0
                duration: 350
                easing.type: Easing.OutElastic
            }
        }
        Text {
            objectName: "lockStatus"
            width: parent.width
            height: 24
            text: root.context.authPending ? "Verifying…" : root.context.showFailure ? root.context.failureMessage : root.context.capsLock ? "Caps Lock" : ""
            color: root.context.showFailure ? Theme.red : root.context.capsLock ? Theme.warning : Theme.subtext1
            font.family: Theme.fontMain
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.PlainText
        }
    }
}
