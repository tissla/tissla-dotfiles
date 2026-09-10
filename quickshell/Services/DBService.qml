pragma Singleton
import QtQuick
import QtQuick.LocalStorage

Item {
    id: root

    property var database: null
    property bool ready: false
    property string errorMessage: ""
    property var calendarNotes: ({})
    property string scratchpadText: ""

    function initialize() {
        ready = false;
        try {
            database = LocalStorage.openDatabaseSync("tissla-quickshell-notes", "1.0", "Calendar and scratchpad notes", 1000000);
            database.transaction(tx => {
                tx.executeSql("CREATE TABLE IF NOT EXISTS calendar_notes (day TEXT PRIMARY KEY, note TEXT NOT NULL)");
                tx.executeSql("CREATE TABLE IF NOT EXISTS calendar_colors (day TEXT NOT NULL, color TEXT NOT NULL, PRIMARY KEY(day, color))");
                tx.executeSql("CREATE TABLE IF NOT EXISTS scratchpad (id INTEGER PRIMARY KEY CHECK(id = 1), note TEXT NOT NULL)");
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
        });
        calendarNotes = notes;
        scratchpadText = scratchpad;
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
