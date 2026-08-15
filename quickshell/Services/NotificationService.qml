import QtQuick
import Quickshell.Services.Notifications
import ".."
pragma Singleton

QtObject {
    id: root

    property var notifications: []
    property NotificationServer server
    property Component notifTimerComponent

    property int maxMessageSize: 80

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
            appName: notif.appName || "",
            image: notif.image || null,
            summary: notif.summary || "",
            body: notif.body.slice(0, maxMessageSize) || "",
            sourceNotif: notif
        }

        // sound (maybe move??)
        PlaySoundService.playSound("message")
        notifications = [item, ...notifications.filter(n => n && n.id !== item.id)]
        const timer = notifTimerComponent.createObject(root)

        timer.triggered.connect(function() {
            removeNotif(item);
            timer.destroy()
        });
    }

    notifTimerComponent: Component {
        Timer {
            interval: 5000
            repeat: false
            running: true
        }
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
