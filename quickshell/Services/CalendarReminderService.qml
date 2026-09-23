pragma Singleton

import QtQuick
import ".."

Item {
    id: root

    property bool started: false
    property bool checking: false

    function start() {
        started = true;
        checkReminders();
    }

    function checkReminders() {
        if (!started || checking || !DBService.ready)
            return;
        checking = true;
        try {
            const now = Date.now();
            const due = DBService.calendarReminders.filter(r => !r.dismissed
                && r.eventAt - r.minutesBefore * 60000 <= now);
            const ids = due.map(r => "local:calendar-" + r.id);
            // Editing or deleting an active reminder also removes its popup.
            for (const notification of NotificationService.notifications) {
                if (String(notification.id).startsWith("local:calendar-") && ids.indexOf(notification.id) === -1)
                    NotificationService.withdrawLocalNotification(String(notification.id).slice(6));
            }
            for (const reminder of due) {
                const key = "calendar-" + reminder.id;
                const body = Qt.formatDateTime(new Date(reminder.eventAt), "yyyy-MM-dd HH:mm");
                const shown = NotificationService.notifications.find(n => n.id === "local:" + key);
                if (shown && shown.summary === reminder.title && shown.body === body)
                    continue;
                // Persist delivery before playing sound so reloads don't ring again.
                if (!reminder.notified && !DBService.markCalendarReminderNotified(reminder.id))
                    continue;
                NotificationService.showLocalNotification(key, "Calendar", reminder.title, body,
                    !reminder.notified && reminder.sound ? "bell" : "",
                    () => DBService.dismissCalendarReminder(reminder.id));
            }
        } finally {
            checking = false;
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.started
        onTriggered: root.checkReminders()
    }

    Connections {
        target: DBService
        function onCalendarRemindersChanged() { Qt.callLater(root.checkReminders); }
        function onReadyChanged() { Qt.callLater(root.checkReminders); }
    }
}
