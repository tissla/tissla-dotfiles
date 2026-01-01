// inspiration and original by bgibson72
// source: github.com/bgibson72/yahr-quickshell
// modified by tissla
// TODO: Refactor this monstrosity

import ".."
import QtQuick
import Quickshell
import Quickshell.Io

// Calendar widget - designed to fill parent window
BaseWidget {
    id: root

    property int selectedDay: -1
    property int selectedMonth: -1
    property int selectedYear: -1
    property int displayMonth: new Date().getMonth()
    property int displayYear: new Date().getFullYear()
    property var now: new Date()
    property string notesFilePath: Quickshell.shellDir + "/data/calendar_notes.json"
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

    function hasNoteForDay(dayId) {
        return notesData[dayId] && notesData[dayId].noteColors && notesData[dayId].noteColors.length > 0;
    }

    function saveAllNotes() {
        let json = JSON.stringify(notesData, null, 2);
        saveNotesProcess.noteText = json;
        saveNotesProcess.running = true;
    }

    function loadAllNotes() {
        loadNotesProcess.running = true;
    }

    function cleanupEmptyNotes() {
        let newData = {
        };
        for (let dayId in notesData) {
            if (notesData[dayId].noteColors && notesData[dayId].noteColors.length > 0)
                newData[dayId] = notesData[dayId];

        }
        notesData = newData;
        saveAllNotes();
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

    function getNoteColorsForDay(dayId) {
        if (!notesData || typeof notesData !== 'object')
            return [];

        if (notesData[dayId] && notesData[dayId].noteColors)
            return notesData[dayId].noteColors;

        return [];
    }

    Component.onCompleted: {
        if (visible)
            resetCalendar();

    }
    onSelectedDayChanged: {
        if (selectedDay !== -1) {
            selectedDayId = selectedYear + "-" + (selectedMonth + 1).toString().padStart(2, '0') + "-" + selectedDay.toString().padStart(2, '0');
            console.log("[Calendar] Selected day ID:", selectedDayId); // Debug
        }
    }
    // update date on show
    onWidgetVisibleChanged: {
        if (widgetVisible) {
            resetCalendar();
            loadAllNotes();
        } else {
            cleanupEmptyNotes();
        }
    }
    widgetWidth: 620
    widgetHeight: 420
    widgetId: "calendar"

    Process {
        id: saveNotesProcess

        property string noteText: ""

        running: false
        command: ["sh", "-c", "mkdir -p '" + Quickshell.shellDir + "/data' && " + "echo '" + noteText.replace(/'/g, "'\\''") + "' > '" + notesFilePath + "'"]
        onRunningChanged: {
            if (!running)
                console.log("[Calendar] Saved colors");

        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0)
                    console.error("[Calendar] Save error:", text);

            }
        }

    }

    Process {
        id: loadNotesProcess

        running: false
        command: ["cat", notesFilePath]

        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim().length > 0) {
                    try {
                        root.notesData = JSON.parse(text);
                        console.log("[Calendar] Loaded colors");
                    } catch (e) {
                        root.notesData = {
                        };
                    }
                } else {
                    root.notesData = {
                    };
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.includes("No such file"))
                    root.notesData = {
                };

            }
        }

    }

    // component
    widgetComponent: Rectangle {
        color: Theme.background
        radius: Theme.radius
        border.width: 3
        border.color: Theme.primary

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
                radius: Theme.radius

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

                        font.family: Theme.fontMain
                        font.pixelSize: 48
                        font.weight: Font.Bold
                        color: Theme.foreground
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
                    radius: Theme.radius

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
                                color: Theme.foreground
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
                                font.family: Theme.fontMain
                                font.pixelSize: 18
                                font.weight: Font.Medium
                                color: Theme.foregroundAlt
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            //  Right arrow
                            Text {
                                width: 40
                                height: 30
                                text: "›"
                                font.pixelSize: 30
                                color: Theme.foreground
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
                                font.family: Theme.fontMain
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
                                    font.family: Theme.fontMain
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: Theme.foreground
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
                                        font.family: Theme.fontMain
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        font.italic: true
                                        color: Theme.info
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
                                        radius: Theme.radiusAlt
                                        border.width: 2
                                        color: {
                                            if (isSelectedDay)
                                                return Theme.inactive;

                                            if (isHovered)
                                                return Theme.primary;

                                            return "transparent";
                                        }
                                        border.color: {
                                            if (isDayInMonth && isCurrentDay)
                                                return Theme.primary;

                                            return "transparent";
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: parent.isSelectedDay ? Qt.ArrowCursor : Qt.PointingHandCursor
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
                                            font.family: Theme.fontMain
                                            font.pixelSize: 13
                                            color: {
                                                if (parent.isSelectedDay)
                                                    return Theme.foreground;

                                                if (parent.isDayInMonth && parent.isCurrentDay)
                                                    return Theme.active;

                                                if (!parent.isDayInMonth)
                                                    return Theme.inactive;

                                                return Theme.foreground;
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
                    radius: Theme.radius

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
                            font.family: Theme.fontMain
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            color: Theme.foreground
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
                            font.family: Theme.fontMain
                            font.pixelSize: 15
                            font.weight: Font.Bold
                            color: Theme.info
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
                            color: Theme.foregroundAlt
                        }

                        // Separator
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.primary
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
                                    radius: Theme.radiusAlt

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (!root.notesData[root.selectedDayId])
                                                root.notesData[root.selectedDayId] = {
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

    }

}
