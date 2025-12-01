// Original by bgibson72
// source: github.com/bgibson72/yahr-quickshell
// modified by tissla

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
    property string filePathBaseDir: Quickshell.env("HOME") + "/.config/quickshell/notes/"
    property string selectedDayId: ""

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

    function loadNotes(path) {
        loadNotesProcess.exec({
            "command": ["cat", path]
        });
    }

    onSelectedDayChanged: {
        if (selectedDay !== -1) {
            if (saveTimer.running)
                saveTimer.stop();

            currentNotesFilePath = getNotesFilePath();
            loadNotesProcess.running = true;
        }
    }
    // update date on show
    onIsVisibleChanged: {
        if (isVisible)
            resetCalendar();

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
            color: Theme.backgroundAlt
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

                    font.family: Theme.fontCalendar
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
                color: Theme.backgroundAlt
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
                            font.family: Theme.fontCalendar
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
                            font.family: Theme.fontCalendar
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
                                font.family: Theme.fontCalendar
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
                                    font.family: Theme.fontCalendar
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    font.italic: true
                                    color: Theme.bbyBlue
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                // cell that represents a day
                                Rectangle {
                                    property int newIndex: index - ((index / 8) * 1)
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
                                    // Which notes exist for this dayId
                                    property var noteColors: ["orange", "blue", Theme.primary]
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
                                    property bool hasNote: File.exists(root.filePathBaseDir + dayId + ".txt")

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
                                                root.selectedDay = parent.dayNumber;
                                                root.selectedMonth = root.displayMonth;
                                                root.selectedYear = root.displayYear;
                                                root.selectedDayId = parent.dayId;
                                                console.log("Selected:", root.selectedDay, root.selectedMonth, root.selectedYear);
                                                const path = root.filePathBaseDir + parent.dayId + ".txt";
                                                loadNotes(path);
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.isDayInMonth ? parent.dayNumber : parent.otherDayNumber
                                        font.family: "JetBrains Nerd Font"
                                        font.pixelSize: 13
                                        color: {
                                            if (parent.isDayInMonth && parent.isCurrentDay)
                                                return Theme.todayText;

                                            if (!parent.isDayInMonth)
                                                return Theme.textMuted;

                                            return Theme.textPrimary;
                                        }
                                        font.weight: parent.isDayInMonth ? Font.Bold : Font.Normal
                                    }

                                    // earmark indicator
                                    Repeater {
                                        model: 3
                                        anchors.top: parent.top
                                        anchors.left: parent.left

                                        Rectangle {
                                            y: index * 6
                                            height: 4
                                            width: 4
                                            color: parent.noteColors[index]
                                            visible: true
                                        }

                                    }

                                    Canvas {
                                        id: noteIndicator

                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        width: parent.width / 4
                                        height: parent.height / 4
                                        visible: parent.hasNote
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.fillStyle = "orange";
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
                color: Theme.backgroundAlt
                radius: 20

                Column {
                    spacing: 12

                    anchors {
                        fill: parent
                        leftMargin: 30
                        rightMargin: 30
                        topMargin: 12
                        bottomMargin: 18
                    }

                    // Date header
                    Text {
                        width: parent.width
                        text: {
                            if (root.selectedDay === -1)
                                return "Select a day";

                            return root.selectedYear + "-" + (root.selectedMonth + 1).toString().padStart(2, '0') + "-" + root.selectedDay.toString().padStart(2, '0');
                        }
                        font.family: Theme.fontCalendar
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
                        height: 150
                        text: ""
                        color: Theme.textPrimary
                        font.family: Theme.fontCalendar
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
                                if (root.selectedDay !== -1 && !root.isNullOrWhiteSpace(notesEdit.text)) {
                                    const path = root.filePathBaseDir + selectedDayId + ".txt";
                                    saveNotesProcess.filePath = path;
                                    saveNotesProcess.noteText = notesEdit.text;
                                    saveNotesProcess.running = true;
                                }
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

                }

            }

        }

    }

    // Save notes
    Process {
        id: saveNotesProcess

        property string filePath: ""
        property string noteText: ""

        running: false
        command: ["sh", "-c", "mkdir -p ~/.config/quickshell/notes && " + "echo '" + noteText.replace(/'/g, "'\\''") + "' > '" + filePath + "'"]
        onRunningChanged: {
            if (!running)
                console.log(`Saved notes ${noteText} to ${filePath}`);

        }
    }

    Process {
        id: loadNotesProcess

        stdout: StdioCollector {
            onStreamFinished: {
                notesEdit.text = text;
                console.log(`Loaded text: ${notesEdit.text}`);
            }
        }

    }

}
