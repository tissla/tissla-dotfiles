import QtQuick
import Quickshell.Services.Notifications
pragma Singleton

QtObject {
    id: root

    property NotificationServer server
    property var notifications: server.trackedNotifications

    server: NotificationServer {
        id: srv

        bodySupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        imageSupported: true
        actionsSupported: true
        inlineReplySupported: true
        keepOnReload: true
        onNotification: (notif) => {
            console.log("NOTIF:", notif.summary, notif.body);
            notif.tracked = true;
            Qt.createQmlObject(`
                import QtQuick
                Timer {
                    interval: 10000
                    running: true
                    repeat: false
                    onTriggered: notif.dismiss()
                }
            `, root);
        }
    }

}
