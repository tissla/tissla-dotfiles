pragma Singleton
import QtQuick
import QtQuick.LocalStorage

Item {
    id: root

    property var database: null
    property bool ready: false
    property string errorMessage: ""
    property var calendarNotes: ({})
    property var calendarReminders: []
    property string scratchpadText: ""

    function initialize() {
        ready = false;
        try {
            database = LocalStorage.openDatabaseSync("tissla-quickshell-notes", "1.0", "Calendar and scratchpad notes", 1000000);
            database.transaction(tx => {
                tx.executeSql("CREATE TABLE IF NOT EXISTS calendar_notes (day TEXT PRIMARY KEY, note TEXT NOT NULL)");
                tx.executeSql("CREATE TABLE IF NOT EXISTS calendar_colors (day TEXT NOT NULL, color TEXT NOT NULL, PRIMARY KEY(day, color))");
                tx.executeSql("CREATE TABLE IF NOT EXISTS scratchpad (id INTEGER PRIMARY KEY CHECK(id = 1), note TEXT NOT NULL)");
                tx.executeSql("CREATE TABLE IF NOT EXISTS calendar_reminders (id INTEGER PRIMARY KEY AUTOINCREMENT, day TEXT NOT NULL, title TEXT NOT NULL, event_at REAL NOT NULL, minutes_before INTEGER NOT NULL, sound INTEGER NOT NULL DEFAULT 1, notified INTEGER NOT NULL DEFAULT 0, dismissed INTEGER NOT NULL DEFAULT 0)");
            });
            reload();
            ready = true;
            errorMessage = "";
        } catch (error) {
            errorMessage = "Could not open notes: " + error;
            console.error("[DBService]", errorMessage);
        }
    }

    function reload() {
        let notes = {};
        let scratchpad = "";
        let reminders = [];
        database.readTransaction(tx => {
            const rows = tx.executeSql("SELECT day, note FROM calendar_notes").rows;
            for (let i = 0; i < rows.length; i++) {
                const row = rows.item(i);
                notes[row.day] = {
                    text: row.note,
                    noteColors: []
                };
            }
            const colors = tx.executeSql("SELECT day, color FROM calendar_colors ORDER BY rowid").rows;
            for (let i = 0; i < colors.length; i++) {
                const row = colors.item(i);
                if (notes[row.day])
                    notes[row.day].noteColors.push(row.color);
            }
            const pad = tx.executeSql("SELECT note FROM scratchpad WHERE id = 1").rows;
            if (pad.length)
                scratchpad = pad.item(0).note;
            const alarms = tx.executeSql("SELECT * FROM calendar_reminders ORDER BY event_at, id").rows;
            for (let i = 0; i < alarms.length; i++) {
                const row = alarms.item(i);
                reminders.push({ id: row.id, day: row.day, title: row.title,
                    eventAt: row.event_at, minutesBefore: row.minutes_before,
                    sound: !!row.sound, notified: !!row.notified, dismissed: !!row.dismissed });
            }
        });
        calendarNotes = notes;
        scratchpadText = scratchpad;
        calendarReminders = reminders;
    }

    function saveCalendarReminder(id, day, title, time, minutesBefore, sound) {
        if (!ready)
            return false;
        const parts = day.split("-").map(Number);
        const clock = time.split(":").map(Number);
        const date = new Date(parts[0], parts[1] - 1, parts[2], clock[0], clock[1]);
        const eventAt = date.getTime();
        if (!/^\d{4}-\d{2}-\d{2}$/.test(day) || !/^([01]\d|2[0-3]):[0-5]\d$/.test(time)
                || !Number.isFinite(eventAt) || date.getFullYear() !== parts[0]
                || date.getMonth() !== parts[1] - 1 || date.getDate() !== parts[2]
                || date.getHours() !== clock[0] || date.getMinutes() !== clock[1]
                || !title.trim() || !Number.isInteger(minutesBefore) || minutesBefore < 0 || minutesBefore > 10080) {
            errorMessage = "Enter a title and a valid time (HH:MM).";
            return false;
        }
        const existing = calendarReminders.find(r => r.id === id);
        if (id !== 0 && !existing) {
            errorMessage = "This reminder no longer exists.";
            return false;
        }
        const rescheduled = !existing || existing.eventAt !== eventAt || existing.minutesBefore !== minutesBefore;
        if (rescheduled && eventAt - minutesBefore * 60000 <= Date.now()) {
            errorMessage = "Choose a reminder time in the future.";
            return false;
        }
        try {
            database.transaction(tx => {
                if (existing) {
                    tx.executeSql("UPDATE calendar_reminders SET day = ?, title = ?, event_at = ?, minutes_before = ?, sound = ?, notified = ?, dismissed = ? WHERE id = ?",
                        [day, title.trim(), eventAt, minutesBefore, sound ? 1 : 0,
                         rescheduled ? 0 : (existing.notified ? 1 : 0), rescheduled ? 0 : (existing.dismissed ? 1 : 0), id]);
                } else {
                    tx.executeSql("INSERT INTO calendar_reminders (day, title, event_at, minutes_before, sound) VALUES (?, ?, ?, ?, ?)",
                        [day, title.trim(), eventAt, minutesBefore, sound ? 1 : 0]);
                }
            });
            reload();
            errorMessage = "";
            return true;
        } catch (error) {
            errorMessage = "Could not save reminder: " + error;
            return false;
        }
    }

    function deleteCalendarReminder(id) {
        return updateReminder("DELETE FROM calendar_reminders WHERE id = ?", id);
    }

    function markCalendarReminderNotified(id) {
        return updateReminder("UPDATE calendar_reminders SET notified = 1 WHERE id = ?", id);
    }

    function dismissCalendarReminder(id) {
        return updateReminder("UPDATE calendar_reminders SET dismissed = 1 WHERE id = ?", id);
    }

    function updateReminder(sql, id) {
        if (!ready)
            return false;
        try {
            database.transaction(tx => tx.executeSql(sql, [id]));
            reload();
            errorMessage = "";
            return true;
        } catch (error) {
            errorMessage = "Could not update reminder: " + error;
            console.error("[DBService]", errorMessage);
            return false;
        }
    }

    function saveCalendarNote(day, text, colors) {
        if (!ready || !/^\d{4}-\d{2}-\d{2}$/.test(day))
            return false;
        try {
            database.transaction(tx => {
                tx.executeSql("DELETE FROM calendar_colors WHERE day = ?", [day]);
                if (!text.trim() && colors.length === 0) {
                    tx.executeSql("DELETE FROM calendar_notes WHERE day = ?", [day]);
                } else {
                    tx.executeSql("INSERT OR REPLACE INTO calendar_notes VALUES (?, ?)", [day, text]);
                    for (const color of colors)
                        tx.executeSql("INSERT OR IGNORE INTO calendar_colors VALUES (?, ?)", [day, color]);
                }
            });
            reload();
            errorMessage = "";
            return true;
        } catch (error) {
            errorMessage = "Could not save notes: " + error;
            return false;
        }
    }

    function saveScratchpad(text) {
        if (!ready)
            return false;
        try {
            database.transaction(tx => tx.executeSql("INSERT OR REPLACE INTO scratchpad VALUES (1, ?)", [text]));
            scratchpadText = text;
            errorMessage = "";
            return true;
        } catch (error) {
            errorMessage = "Could not save notes: " + error;
            return false;
        }
    }

    Component.onCompleted: initialize()
}
