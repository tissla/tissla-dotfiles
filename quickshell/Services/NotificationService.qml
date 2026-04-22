import QtQuick
import Quickshell.Services.Notifications
import ".."
pragma Singleton

QtObject {
    id: root

    property var notifications: []
    property NotificationServer server

    function removeNotif(item) {

        
        notifications = notifications.filter(n => n && n.id !== item.id);
        
        if (item.sourceNotif)
            item.sourceNotif.tracked = false

        console.log("Removed notification id:", item.id);
    }

    function handleNotif(notif) {
        notif.tracked = true

        // convert to local item
        const item = {
                id: notif.id,
                summary: notif.summary || "",
                body: notif.body || "",
                sourceNotif: notif
            }

        notifications = [item, ...notifications.filter(n => n && n.id !== item.id)]
        const timer = Qt.createQmlObject(`
            import QtQuick

            Timer {
                interval: 5000
                repeat: false
                running: true
            }
        `, root, "notif_timer")

        timer.triggered.connect(function() {
            removeNotif(item);
            timer.destroy()
        });
    }

    server: NotificationServer {
        bodySupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        imageSupported: true
        actionsSupported: true
        inlineReplySupported: true
        keepOnReload: true
        onNotification: function(notif) {
            console.log("Received notification:", notif.summary);
            console.log("Notifications contain:", notifications.map(n => n.id))
            root.handleNotif(notif);
        }
    }

}
