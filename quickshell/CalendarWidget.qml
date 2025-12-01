// Original by bgibson72
// source: github.com/bgibson72/yahr-quickshell
// modified by tissla

import QtQuick
import Quickshell
import Quickshell.Io

// Calendar widget - designed to fill parent window
Rectangle {
    id: root

    property bool isVisible: false
    property int displayMonth: new Date().getMonth()
    property int displayYear: new Date().getFullYear()
    property var now: new Date()

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

    //function to reset calendar display to current month
    function resetCalendar() {
        now = new Date();
        displayMonth = now.getMonth();
        displayYear = now.getFullYear();
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

        // Bottom row: Calendar
        Row {
            width: parent.width
            height: parent.height - 80 - 12 // Subtract time section height and spacing
            spacing: 12

            // Calendar Section
            Rectangle {
                width: parent.width // Fill remaining space
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
                            font.pixelSize: 24
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
                            font.pixelSize: 24
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
                        width: parent.width
                        columns: 8
                        columnSpacing: 6
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

                                Text {
                                    visible: index % 8 === 0
                                    anchors.fill: parent
                                    text: {
                                        // calc week
                                        let date = new Date(root.displayYear, root.displayMonth, Math.floor(index / 7) * 7 + 1);
                                        return getWeekNumber(date);
                                    }
                                    font.family: Theme.fontCalendar
                                    font.pixelSize: 13
                                    color: Theme.todayText
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

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

                                    visible: index % 8 !== 0
                                    anchors.fill: parent
                                    width: 40
                                    height: 30
                                    radius: 0
                                    border.width: 2
                                    color: "transparent"
                                    border.color: {
                                        if (isDayInMonth && isCurrentDay)
                                            return Theme.primary;

                                        return "transparent";
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: {
                                            parent.color = Theme.primary;
                                        }
                                        onExited: {
                                            parent.color = "transparent";
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

                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
