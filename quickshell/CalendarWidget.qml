// Original by bgibson72
// source: github.com/bgibson72/yahr-quickshell
// modified by tissla

import QtQuick
import Quickshell
import Quickshell.Io

// Calendar widget - designed to fill parent window
Rectangle {
    id: root

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

                    // Calendar header - single line
                    Text {
                        width: parent.width
                        text: {
                            const now = new Date();
                            const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
                            return monthNames[now.getMonth()] + " " + now.getFullYear();
                        }
                        font.family: "JetBrains Nerd Font"
                        font.pixelSize: 18
                        font.weight: Font.Medium
                        color: Theme.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Calendar grid
                    Grid {
                        width: parent.width
                        columns: 7
                        columnSpacing: 6
                        rowSpacing: 5

                        // Day headers
                        Repeater {
                            model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

                            Text {
                                text: modelData
                                font.family: "JetBrains Nerd Font"
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
                            model: 42

                            Rectangle {
                                property var now: new Date()
                                property int currentDay: now.getDate()
                                property int currentMonth: now.getMonth()
                                property int currentYear: now.getFullYear()
                                // Calculate what day this cell represents
                                property var firstDay: new Date(currentYear, currentMonth, 1)
                                property int startOffset: firstDay.getDay() // 0 = Sunday
                                property int dayNumber: index - startOffset + 1
                                property var lastDay: new Date(currentYear, currentMonth + 1, 0)
                                property int daysInMonth: lastDay.getDate()
                                property bool isCurrentDay: dayNumber === currentDay
                                property bool isDayInMonth: dayNumber >= 1 && dayNumber <= daysInMonth
                                property var lastMonthsLastDay: new Date(currentYear, currentMonth, 0)
                                property int lastMonthDays: lastMonthsLastDay.getDate()
                                // last month check
                                property bool isLastMonth: dayNumber < 1
                                // dayNumber is negative leading up to month start
                                property int lastMonthNumber: lastMonthDays + dayNumber
                                // Becomes 1 when past our month
                                property int nextMonthNumber: dayNumber - daysInMonth
                                // check if day is outside of month
                                property int otherDayNumber: isLastMonth ? lastMonthNumber : nextMonthNumber

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
