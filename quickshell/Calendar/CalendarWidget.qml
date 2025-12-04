// inspiration and original by bgibson72
// source: github.com/bgibson72/yahr-quickshell
// modified by tissla

import ".."
import QtQuick
import Quickshell
import Quickshell.Io

// Calendar widget - designed to fill parent window
Rectangle {
    id: root

    property int selectedDay: -1
    property int selectedMonth: -1
    property int selectedYear: -1
    property bool isVisible: false
    property int displayMonth: new Date().getMonth()
    property int displayYear: new Date().getFullYear()
    property var now: new Date()
    property string notesFilePath: Quickshell.env("HOME") + "/.config/quickshell/data/calendar_notes.json"
    property string selectedDayId: ""
    property var notesData: ({
    })

    // function to change month/year
    function changeMonth(offset) {
        displayMonth = displayMonth + offset;
        if (displayMonth > 11) {
            displayMonth = 0;
            displayYear++;
        } else if (displayMonth < 0) {
            displayMonth = 11;
            displayYear--;
        }
    }

    function isNullOrWhiteSpace(str) {
        return !str || str.trim().length === 0;
    }

    //function to reset calendar display to current month
    function resetCalendar() {
        now = new Date();
        displayMonth = now.getMonth();
        displayYear = now.getFullYear();
        selectedDay = -1;
        selectedMonth = -1;
        selectedYear = -1;
    }

    // calculate week number
    function getWeekNumber(date) {
        // ISO 8601 week number
        let d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
        let dayNum = d.getUTCDay() || 7;
        d.setUTCDate(d.getUTCDate() + 4 - dayNum);
        let yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
        return Math.ceil((((d - yearStart) / 8.64e+07) + 1) / 7);
    }

    // note helpers
    function loadAllNotes() {
        loadNotesProcess.running = true;
    }

    function saveAllNotes() {
        const jsonString = JSON.stringify(notesData, null, 2);
        saveNotesProcess.noteText = jsonString;
        saveNotesProcess.running = true;
    }

    function getNotesForDay(dayId) {
        if (notesData && notesData[dayId] && notesData[dayId].notes)
            return notesData[dayId].notes;

        return "";
    }

    function getNoteColorsForDay(dayId) {
        if (!notesData || typeof notesData !== 'object')
            return [];

        if (notesData[dayId] && notesData[dayId].noteColors)
            return notesData[dayId].noteColors;

        return [];
    }

    function hasNoteForDay(dayId) {
        if (!notesData)
            return false;

        if (typeof notesData !== 'object')
            return false;

        if (!dayId)
            return false;

        if (!notesData[dayId])
            return false;

        if (!notesData[dayId].notes)
            return false;

        if (isNullOrWhiteSpace(notesData[dayId].notes))
            return false;

        return true;
    }

    function saveNoteForDay(dayId, noteText) {
        // use copy
        let newData = Object.assign({
        }, notesData);
        if (isNullOrWhiteSpace(noteText)) {
            // empty = remove
            if (newData[dayId])
                delete newData[dayId];

        } else {
            if (!newData[dayId])
                newData[dayId] = {
                "noteColors": []
            };

            newData[dayId].notes = noteText;
        }
        // reference change to trigger binding update
        notesData = newData;
        saveAllNotes();
    }

    Component.onCompleted: {
        if (visible) {
            resetCalendar();
            loadAllNotes();
        }
    }
    onSelectedDayChanged: {
        if (selectedDay !== -1) {
            if (saveTimer.running)
                saveTimer.stop();

            selectedDayId = selectedYear + "-" + (selectedMonth + 1).toString().padStart(2, '0') + "-" + selectedDay.toString().padStart(2, '0');
            // load from data
            notesEdit.text = getNotesForDay(selectedDayId);
        }
    }
    // update date on show
    onIsVisibleChanged: {
        if (visible) {
            resetCalendar();
            loadAllNotes();
        }
    }
    // base look
    color: Theme.background
    radius: 20
    border.width: 3
    border.color: Theme.primary
    antialiasing: true

    // Main content - use Column since Grid doesn't support colspan
    Column {
        spacing: 12

        anchors {
            fill: parent
            margins: 16
            bottomMargin: 20
        }

        // Time Section (full width)
        Rectangle {
            id: timeSection

            width: parent.width
            height: 80
            color: Theme.backgroundAltSolid
            radius: 20

            // Function to time display based on current settings
            SystemClock {
                id: clock

                precision: SystemClock.Seconds
            }

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    id: timeText

                    font.family: Theme.fontMono
                    font.pixelSize: 48
                    font.weight: Font.Bold
                    color: Theme.textPrimary
                    text: Qt.formatDateTime(clock.date, "hh:mm:ss")
                }

            }

        }

        // Bottom row: Calendar + Dayinfo
        Row {
            width: parent.width
            height: parent.height - 80 - 12 // Subtract time section height and spacing
            spacing: 12

            // Calendar Section
            Rectangle {
                width: 380
                height: parent.height
                color: Theme.backgroundAltSolid
                radius: 20

                Column {
                    spacing: 6

                    anchors {
                        fill: parent
                        leftMargin: 30
                        rightMargin: 30
                        topMargin: 12
                        bottomMargin: 18
                    }

                    // Calendar header with navigation
                    Row {
                        width: parent.width
                        height: 30
                        spacing: 0

                        // left arrow
                        Text {
                            width: 40
                            height: 30
                            text: "‹"
                            font.pixelSize: 30
                            color: Theme.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.changeMonth(-1)
                            }

                        }

                        // Month+Year
                        Text {
                            width: parent.width - 80
                            height: 30
                            text: {
                                const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
                                return monthNames[root.displayMonth] + " " + root.displayYear;
                            }
                            font.family: Theme.fontMono
                            font.pixelSize: 18
                            font.weight: Font.Medium
                            color: Theme.textSecondary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        //  Right arrow
                        Text {
                            width: 40
                            height: 30
                            text: "›"
                            font.pixelSize: 30
                            color: Theme.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.changeMonth(1)
                            }

                        }

                    }

                    // Calendar grid
                    Grid {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: -15
                        columns: 8
                        columnSpacing: 4
                        rowSpacing: 5

                        // empty cell in top left, maybe add something?
                        Text {
                            text: ""
                            font.family: Theme.fontMono
                            width: 40
                            height: 30
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        // Day headers
                        Repeater {
                            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                            Text {
                                text: modelData
                                font.family: Theme.fontMono
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: Theme.textPrimary
                                width: 40
                                height: 24
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                        }

                        // Calendar days - properly calculated using current date
                        Repeater {
                            // 8 (week# + weekdays) * 6 (weeks) = 48
                            model: 48

                            Item {
                                width: 40
                                height: 30

                                // week-indicators
                                Text {
                                    visible: index % 8 === 0
                                    anchors.fill: parent
                                    text: {
                                        // calc week
                                        let date = new Date(root.displayYear, root.displayMonth, Math.floor(index / 7) * 7 + 1);
                                        return getWeekNumber(date);
                                    }
                                    font.family: Theme.fontMono
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    font.italic: true
                                    color: Theme.bbyBlue
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                // cell that represents a day
                                Rectangle {
                                    property int newIndex: index - ((index / 8))
                                    // current day
                                    property int currentDay: root.now.getDate()
                                    // Calculate what day this cell represents
                                    property var firstDay: new Date(root.displayYear, root.displayMonth, 1)
                                    // offset (sunday = 0, monday = 1, etc)
                                    property int startOffset: {
                                        let day = firstDay.getDay();
                                        return day === 0 ? 6 : day - 1;
                                    }
                                    // daynumber (negative values for last month)
                                    property int dayNumber: newIndex - startOffset + 1
                                    property var lastDay: new Date(root.displayYear, root.displayMonth + 1, 0)
                                    // get number of days in current month
                                    property int daysInMonth: lastDay.getDate()
                                    property bool isCurrentDay: dayNumber === currentDay && root.displayMonth === root.now.getMonth() && root.displayYear === root.now.getFullYear()
                                    property bool isDayInMonth: dayNumber >= 1 && dayNumber <= daysInMonth
                                    property var lastMonthsLastDay: new Date(root.displayYear, root.displayMonth, 0)
                                    property int lastMonthDays: lastMonthsLastDay.getDate()
                                    // last month check
                                    property bool isLastMonth: dayNumber < 1
                                    // dayNumber is negative leading up to month start
                                    property int lastMonthNumber: lastMonthDays + dayNumber
                                    // Becomes 1 when past our month
                                    property int nextMonthNumber: dayNumber - daysInMonth
                                    // check if day is outside of month
                                    property int otherDayNumber: isLastMonth ? lastMonthNumber : nextMonthNumber
                                    property bool isSelectedDay: dayNumber == root.selectedDay && root.selectedMonth == root.displayMonth && root.selectedYear == root.displayYear
                                    property bool isHovered: false
                                    // day ID helpers
                                    property int cellYear: {
                                        if (isLastMonth)
                                            return displayMonth === 0 ? displayYear - 1 : displayYear;

                                        if (dayNumber > daysInMonth)
                                            return displayMonth === 11 ? displayYear + 1 : displayYear;

                                        return displayYear;
                                    }
                                    property int cellMonth: {
                                        if (isLastMonth)
                                            return displayMonth === 0 ? 11 : displayMonth - 1;

                                        if (dayNumber > daysInMonth)
                                            return displayMonth === 11 ? 0 : displayMonth + 1;

                                        return displayMonth;
                                    }
                                    property int cellDay: {
                                        if (isLastMonth)
                                            return lastMonthNumber;

                                        if (dayNumber > daysInMonth)
                                            return nextMonthNumber;

                                        return dayNumber;
                                    }
                                    // unique ID for cell
                                    property string dayId: cellYear + "-" + (cellMonth + 1).toString().padStart(2, '0') + "-" + cellDay.toString().padStart(2, '0')
                                    // check if we have a note for day
                                    property bool hasNote: root.hasNoteForDay(dayId) || false
                                    property var dayNoteColors: root.getNoteColorsForDay(dayId)

                                    visible: index % 8 !== 0
                                    anchors.fill: parent
                                    width: 40
                                    height: 30
                                    radius: 0
                                    border.width: 2
                                    color: {
                                        if (isSelectedDay)
                                            return Theme.primary;

                                        if (isHovered)
                                            return Theme.bbyBlue;

                                        return "transparent";
                                    }
                                    border.color: {
                                        if (isDayInMonth && isCurrentDay)
                                            return Theme.primary;

                                        return "transparent";
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: {
                                            parent.isHovered = true;
                                        }
                                        onExited: {
                                            parent.isHovered = false;
                                        }
                                        onClicked: {
                                            if (parent.isDayInMonth) {
                                                root.selectedYear = root.displayYear;
                                                root.selectedMonth = root.displayMonth;
                                                root.selectedDay = parent.dayNumber;
                                                console.log("Selected:", root.selectedDay, root.selectedMonth, root.selectedYear);
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.isDayInMonth ? parent.dayNumber : parent.otherDayNumber
                                        font.family: Theme.fontMono
                                        font.pixelSize: 13
                                        color: {
                                            if (parent.isSelectedDay)
                                                return Theme.accent;

                                            if (parent.isDayInMonth && parent.isCurrentDay)
                                                return Theme.todayText;

                                            if (!parent.isDayInMonth)
                                                return Theme.textMuted;

                                            return Theme.textPrimary;
                                        }
                                        font.weight: parent.isDayInMonth ? Font.Bold : Font.Normal
                                    }

                                    // colored note indicators
                                    Repeater {
                                        model: root.notesData[parent.dayId] ? root.notesData[parent.dayId].noteColors : []
                                        anchors.top: parent.top
                                        anchors.left: parent.left

                                        Rectangle {
                                            y: index * 10
                                            height: 8
                                            width: 8
                                            color: modelData
                                            visible: true
                                        }

                                    }

                                    // has note earmark
                                    Canvas {
                                        id: noteIndicator

                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        width: parent.width / 4
                                        height: parent.height / 4
                                        visible: root.hasNoteForDay(parent.dayId) || false
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.fillStyle = Theme.accent;
                                            ctx.beginPath();
                                            ctx.moveTo(width, 0);
                                            ctx.lineTo(0, 0);
                                            ctx.lineTo(width, height);
                                            ctx.closePath();
                                            ctx.fill();
                                        }
                                    }

                                }

                            }

                        }

                    }

                }

            }

            // day info	section
            Rectangle {
                // fill remaining space, 380 is calendar and 12 for spacing
                width: parent.width - 380 - 12
                height: parent.height
                color: Theme.backgroundAltSolid
                radius: 20

                Column {
                    spacing: 12

                    anchors {
                        fill: parent
                        leftMargin: 30
                        rightMargin: 30
                        topMargin: 12
                    }

                    // Date header
                    Text {
                        width: parent.width
                        text: {
                            if (root.selectedDay === -1)
                                return "Select a day";

                            return root.selectedYear + "-" + (root.selectedMonth + 1).toString().padStart(2, '0') + "-" + root.selectedDay.toString().padStart(2, '0');
                        }
                        font.family: Theme.fontMono
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter
                        color: Theme.textPrimary
                    }

                    // Day of week
                    Text {
                        text: {
                            if (root.selectedDay === -1)
                                return "";

                            let date = new Date(root.selectedYear, root.selectedMonth, root.selectedDay);
                            const dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                            return dayNames[date.getDay()];
                        }
                        font.family: "Rubik SemiBold"
                        font.pixelSize: 15
                        color: Theme.bbyBlue
                    }

                    // Week
                    Text {
                        text: {
                            if (root.selectedDay === -1)
                                return "";

                            let date = new Date(root.selectedYear, root.selectedMonth, root.selectedDay);
                            return "Week " + root.getWeekNumber(date);
                        }
                        font.pixelSize: 12
                        color: Theme.textMuted
                    }

                    // Separator
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.primary
                    }

                    // Notes area
                    TextEdit {
                        id: notesEdit

                        visible: root.selectedDay !== -1
                        width: parent.width
                        height: 115
                        text: ""
                        color: Theme.textPrimary
                        font.family: Theme.fontMono
                        font.pixelSize: 12
                        wrapMode: TextEdit.Wrap
                        selectByMouse: true
                        cursorVisible: true
                        activeFocusOnPress: true
                        onTextChanged: {
                            if (root.selectedDay !== -1)
                                saveTimer.restart();

                        }

                        Timer {
                            id: saveTimer

                            interval: 1000
                            repeat: false
                            onTriggered: {
                                if (root.selectedDay !== -1)
                                    root.saveNoteForDay(root.selectedDayId, notesEdit.text);

                            }
                        }

                        // Placeholder
                        Text {
                            anchors.fill: parent
                            text: "Add notes..."
                            color: Theme.textMuted
                            font: parent.font
                            visible: parent.text === ""
                            enabled: false
                        }

                    }

                    Row {
                        spacing: 10
                        visible: root.selectedDay !== -1
                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {
                            model: ["orange", "green", "red"]

                            Rectangle {
                                width: 30
                                height: 30
                                border.width: 2
                                border.color: modelData
                                color: {
                                    let colors = root.getNoteColorsForDay(root.selectedDayId);
                                    if (colors.indexOf(modelData) !== -1)
                                        return modelData;
                                    else
                                        return "transparent";
                                }
                                radius: 6

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (!root.notesData[root.selectedDayId])
                                            root.notesData[root.selectedDayId] = {
                                            "notes": "",
                                            "noteColors": []
                                        };

                                        let colors = root.notesData[root.selectedDayId].noteColors;
                                        let index = colors.indexOf(modelData);
                                        if (index !== -1)
                                            colors.splice(index, 1);
                                        else
                                            colors.push(modelData);
                                        root.notesData[root.selectedDayId].noteColors = colors;
                                        root.saveAllNotes();
                                        root.notesDataChanged();
                                    }
                                }

                            }

                        }

                    }

                }

            }

        }

    }

    // saveNotesProcess:
    Process {
        id: saveNotesProcess

        property string noteText: ""

        running: false
        command: ["sh", "-c", "mkdir -p ~/.config/quickshell/data && " + "echo '" + noteText.replace(/'/g, "'\\''") + "' > '" + notesFilePath + "'"]
        onRunningChanged: {
            if (!running)
                console.log("Saved notes to JSON");

        }
    }

    // loadNotesProcess:
    Process {
        id: loadNotesProcess

        running: false
        command: ["cat", notesFilePath]

        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim().length > 0) {
                    try {
                        root.notesData = JSON.parse(text);
                        console.log("Loaded notes from JSON");
                        // Update UI if day chosen
                        if (root.selectedDay !== -1)
                            notesEdit.text = root.getNotesForDay(root.selectedDayId);

                    } catch (e) {
                        console.log("Error parsing JSON:", e);
                        root.notesData = {
                        };
                    }
                } else {
                    // Empty data
                    root.notesData = {
                    };
                    console.log("No existing notes file, initialized empty data");
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                // No file handling
                if (text.includes("No such file")) {
                    root.notesData = {
                    };
                    console.log("Notes file doesn't exist yet, initialized empty data");
                }
            }
        }

    }

}
