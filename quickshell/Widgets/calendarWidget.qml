import ".."
import QtQuick
import Quickshell
import QtQuick.Controls

// Calendar widget - designed to fill parent window
BaseWidget {
    id: root

    property int selectedDay: -1
    property int selectedMonth: -1
    property int selectedYear: -1
    property int displayMonth: new Date().getMonth()
    property int displayYear: new Date().getFullYear()
    property var now: new Date()
    readonly property string selectedDayId: selectedDay < 0 ? "" : selectedYear + "-" + (selectedMonth + 1).toString().padStart(2, '0') + "-" + selectedDay.toString().padStart(2, '0')
    readonly property var notesData: DBService.calendarNotes
    property string noteText: ""
    property var noteColors: []
    property bool dirty: false

    function saveNote() {
        if (!dirty)
            return true;
        if (!DBService.saveCalendarNote(selectedDayId, noteText, noteColors))
            return false;
        dirty = false;
        return true;
    }

    function selectDay(year, month, day) {
        if (!saveNote())
            return;
        selectedYear = year;
        selectedMonth = month;
        selectedDay = day;
        const note = notesData[selectedDayId];
        noteText = note ? note.text : "";
        noteColors = note ? note.noteColors.slice() : [];
    }

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
        const note = notesData[dayId];
        return !!note && (note.text.trim().length > 0 || note.noteColors.length > 0);
    }

    //function to reset calendar display to current month
    function resetCalendar() {
        now = new Date();
        displayMonth = now.getMonth();
        displayYear = now.getFullYear();
        selectDay(now.getFullYear(), now.getMonth(), now.getDate());
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
    onVisibleChanged: {
        if (!visible)
            pointerInside = false;
        if (visible && !dirty)
            resetCalendar();
        else if (!visible)
            saveNote();
    }
    // Only request native keyboard focus while the pointer is in the popup.
    // Taking focus during the module's opening click disrupts subsequent clicks.
    property bool pointerInside: false
    focusable: visible && pointerInside
    widgetWidth: 820
    widgetHeight: 470
    widgetId: "calendar"

    // component
    widgetComponent: Rectangle {
        HoverHandler {
            onHoveredChanged: root.pointerInside = hovered
        }

        color: Theme.base
        radius: Theme.radius
        border.width: 3
        border.color: Theme.accent

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
                color: Theme.surface1
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
                        color: Theme.text
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
                    color: Theme.surface1
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
                                color: Theme.text
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
                                color: Theme.info
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            //  Right arrow
                            Text {
                                width: 40
                                height: 30
                                text: "›"
                                font.pixelSize: 30
                                color: Theme.text
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
                                    color: Theme.text
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
                                            let first = new Date(root.displayYear, root.displayMonth, 1);
                                            let offset = (first.getDay() + 6) % 7;
                                            let date = new Date(root.displayYear, root.displayMonth, Math.floor(index / 8) * 7 + 1 - offset);
                                            return getWeekNumber(date);
                                        }
                                        font.family: Theme.fontMain
                                        font.pixelSize: Theme.fontSizeSm
                                        font.weight: Font.Bold
                                        font.italic: true
                                        color: Theme.info
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    // cell that represents a day
                                    Rectangle {
                                        property int newIndex: Math.floor(index / 8) * 7 + (index % 8) - 1
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
                                                return Theme.muted;

                                            if (isHovered)
                                                return Theme.accent;

                                            return "transparent";
                                        }
                                        border.color: {
                                            if (isDayInMonth && isCurrentDay)
                                                return Theme.accent;

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
                                                    root.selectDay(root.displayYear, root.displayMonth, parent.dayNumber);
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
                                                    return Theme.text;

                                                if (parent.isDayInMonth && parent.isCurrentDay)
                                                    return Theme.success;

                                                if (!parent.isDayInMonth)
                                                    return Theme.muted;

                                                return Theme.text;
                                            }
                                            font.weight: parent.isDayInMonth ? Font.Bold : Font.Normal
                                        }

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            width: 5
                                            height: 5
                                            radius: 3
                                            color: Theme.accent
                                            visible: parent.hasNote
                                        }

                                        // colored note indicators
                                        Repeater {
                                            model: root.notesData[parent.dayId] ? root.notesData[parent.dayId].noteColors : []

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
                    color: Theme.surface1
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
                            text: root.selectedDayId || "Select a day"
                            font.family: Theme.fontMain
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            color: Theme.text
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
                            font.pixelSize: Theme.fontSizeXxs
                            color: Theme.subtext1
                        }

                        // Separator
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.accent
                        }

                        ScrollView {
                            width: parent.width
                            height: 140
                            clip: true
                            TextArea {
                                objectName: "calendarNoteEditor"
                                enabled: root.selectedDay !== -1 && DBService.ready
                                text: root.noteText
                                placeholderText: "Notes for this day…"
                                wrapMode: TextEdit.Wrap
                                color: Theme.text
                                placeholderTextColor: Theme.subtext1
                                selectionColor: Theme.accent
                                font.family: Theme.fontMain
                                font.pixelSize: Theme.fontSizeBase
                                background: Rectangle { color: Theme.base; radius: Theme.radiusAlt }
                                onTextChanged: {
                                    if (activeFocus && text !== root.noteText) {
                                        root.noteText = text;
                                        root.dirty = true;
                                        root.saveNote();
                                    }
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            text: DBService.errorMessage || (root.dirty ? "Unsaved changes" : "Saved automatically")
                            color: DBService.errorMessage ? Theme.red : Theme.subtext1
                            wrapMode: Text.Wrap
                            font.pixelSize: Theme.fontSizeXxs
                        }

                        Row {
                            spacing: 10
                            visible: root.selectedDay !== -1
                            enabled: DBService.ready
                            anchors.horizontalCenter: parent.horizontalCenter

                            Repeater {
                                model: ["orange", "green", "red"]

                                Rectangle {
                                    width: 30
                                    height: 30
                                    border.width: 2
                                    border.color: modelData
                                    color: {
                                        let colors = root.noteColors;
                                        if (colors.indexOf(modelData) !== -1)
                                            return modelData;
                                        else
                                            return "transparent";
                                    }
                                    radius: Theme.radiusAlt

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            let colors = root.noteColors.slice();
                                            let index = colors.indexOf(modelData);
                                            if (index !== -1)
                                                colors.splice(index, 1);
                                            else
                                                colors.push(modelData);
                                            root.noteColors = colors;
                                            root.dirty = true;
                                            root.saveNote();
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
