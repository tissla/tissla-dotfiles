pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

ColumnLayout {
    id: root

    required property string day
    property int editingId: 0
    property bool editing: false
    property string errorMessage: ""
    readonly property var reminders: DBService.calendarReminders.filter(r => r.day === day)
    readonly property var leadTimes: [0, 5, 15, 30, 60, 1440]
    signal saved()
    signal cancelled()
    spacing: 8

    function editReminder(reminder) {
        editingId = reminder ? reminder.id : 0;
        titleInput.text = reminder ? reminder.title : "";
        const nextHour = new Date(Date.now() + 3600000);
        timeInput.text = reminder ? Qt.formatDateTime(new Date(reminder.eventAt), "HH:mm")
            : (day === Qt.formatDateTime(new Date(), "yyyy-MM-dd") ? Qt.formatDateTime(nextHour, "HH:mm") : "09:00");
        leadInput.currentIndex = reminder ? Math.max(0, leadTimes.indexOf(reminder.minutesBefore)) : 0;
        soundInput.checked = reminder ? reminder.sound : true;
        errorMessage = "";
        editing = true;
        titleInput.forceActiveFocus();
    }

    function saveReminder() {
        if (DBService.saveCalendarReminder(editingId, day, titleInput.text, timeInput.text,
                leadTimes[leadInput.currentIndex], soundInput.checked)) {
            editing = false;
            errorMessage = "";
            saved();
        } else {
            errorMessage = DBService.errorMessage;
        }
    }

    onDayChanged: {
        editing = false;
        errorMessage = "";
    }

    RowLayout {
        Layout.fillWidth: true
        Text {
            text: "Reminders"
            color: Theme.text
            font.family: Theme.fontMain
            font.pixelSize: Theme.fontSizeBase
            font.bold: true
            Layout.fillWidth: true
        }
        ActionButton {
            objectName: "addAnotherReminderButton"
            text: "+"
            Accessible.name: "Add reminder"
            enabled: root.day !== "" && DBService.ready
            onClicked: root.editReminder(null)
        }
    }

    ColumnLayout {
        visible: root.editing
        Layout.fillWidth: true
        spacing: 8

        TextField {
            id: titleInput
            objectName: "reminderTitleInput"
            Layout.fillWidth: true
            placeholderText: "Title"
            color: Theme.text
            placeholderTextColor: Theme.subtext1
            selectionColor: Theme.accent
            font.family: Theme.fontMain
            font.pixelSize: Theme.fontSizeSm
            maximumLength: 160
            background: Rectangle {
                color: Theme.baseSolid
                radius: Theme.radiusAlt
                border.width: 1
                border.color: titleInput.activeFocus ? Theme.accent : Theme.overlay0
            }
            Accessible.name: "Reminder title"
            onAccepted: root.saveReminder()
        }

        RowLayout {
            Layout.fillWidth: true
            TextField {
                id: timeInput
                objectName: "reminderTimeInput"
                Layout.preferredWidth: 72
                placeholderText: "HH:MM"
                maximumLength: 5
                color: Theme.text
                selectionColor: Theme.accent
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeSm
                horizontalAlignment: TextInput.AlignHCenter
                validator: RegularExpressionValidator { regularExpression: /^([01]\d|2[0-3]):[0-5]\d$/ }
                background: Rectangle {
                    color: Theme.baseSolid
                    radius: Theme.radiusAlt
                    border.width: 1
                    border.color: timeInput.activeFocus ? Theme.accent : Theme.overlay0
                }
                Accessible.name: "Event time (HH:MM)"
                onAccepted: root.saveReminder()
            }
            ComboBox {
                id: leadInput
                objectName: "reminderLeadInput"
                Layout.fillWidth: true
                model: ["At start", "5 min before", "15 min before", "30 min before", "1 hour before", "1 day before"]
                font.family: Theme.fontMain
                font.pixelSize: Theme.fontSizeSm
                palette.button: Theme.baseSolid
                palette.buttonText: Theme.text
                palette.base: Theme.baseSolid
                palette.text: Theme.text
                palette.highlight: Theme.accent
                palette.highlightedText: Theme.baseSolid
                Accessible.name: "Remind me"

                delegate: ItemDelegate {
                    id: option
                    required property var modelData
                    required property int index
                    width: leadInput.width - 2
                    highlighted: leadInput.highlightedIndex === index
                    contentItem: Text {
                        text: option.modelData
                        font: leadInput.font
                        color: Theme.text
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: option.highlighted || option.hovered ? Theme.surface2 : Theme.baseSolid
                    }
                }

                popup: Popup {
                    y: leadInput.height
                    width: leadInput.width
                    padding: 1
                    implicitHeight: Math.min(contentItem.implicitHeight + 2, 260)
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: leadInput.popup.visible ? leadInput.delegateModel : null
                        currentIndex: leadInput.highlightedIndex
                        ScrollIndicator.vertical: ScrollIndicator {}
                    }
                    background: Rectangle {
                        color: Theme.baseSolid
                        border.color: Theme.overlay0
                        border.width: 1
                        radius: Theme.radiusAlt
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            CheckBox {
                id: soundInput
                objectName: "reminderSoundInput"
                text: "Sound"
                checked: true
                font.family: Theme.fontMain
                font.pixelSize: Theme.fontSizeSm
                palette.windowText: Theme.text
                palette.button: Theme.baseSolid
                palette.highlight: Theme.accent
                Layout.fillWidth: true
            }
            ActionButton {
                text: "Cancel"
                onClicked: { root.editing = false; root.errorMessage = ""; root.cancelled(); }
            }
            ActionButton {
                objectName: "saveReminderButton"
                text: "Save"
                enabled: DBService.ready && titleInput.text.trim().length > 0 && timeInput.acceptableInput
                onClicked: root.saveReminder()
            }
        }
    }

    Text {
        Layout.fillWidth: true
        visible: text.length > 0
        text: root.errorMessage
        wrapMode: Text.Wrap
        color: Theme.red
        font.pixelSize: Theme.fontSizeXxs
    }

    Repeater {
        model: root.reminders
        delegate: Rectangle {
            id: reminderRow
            required property var modelData
            Layout.fillWidth: true
            implicitHeight: reminderContent.implicitHeight + 16
            color: Theme.baseSolid
            radius: Theme.radiusAlt

            RowLayout {
                id: reminderContent
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3
                    Text {
                        Layout.fillWidth: true
                        text: reminderRow.modelData.title
                        wrapMode: Text.Wrap
                        color: reminderRow.modelData.dismissed ? Theme.subtext1 : Theme.text
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                    }
                    Text {
                        Layout.fillWidth: true
                        text: Qt.formatDateTime(new Date(reminderRow.modelData.eventAt), "HH:mm")
                            + (reminderRow.modelData.minutesBefore ? " · " + reminderRow.modelData.minutesBefore + " min before" : "")
                            + (reminderRow.modelData.dismissed ? " · Dismissed" : (reminderRow.modelData.notified ? " · Notified" : ""))
                        wrapMode: Text.Wrap
                        color: Theme.subtext1
                        font.pixelSize: Theme.fontSizeTiny
                    }
                }
                ActionButton {
                    text: "Edit"
                    Accessible.name: "Edit " + reminderRow.modelData.title
                    onClicked: root.editReminder(reminderRow.modelData)
                }
                ActionButton {
                    text: "×"
                    Accessible.name: "Delete " + reminderRow.modelData.title
                    onClicked: {
                        const id = reminderRow.modelData.id;
                        if (!DBService.deleteCalendarReminder(id)) {
                            root.errorMessage = DBService.errorMessage;
                        } else if (root.editingId === id) {
                            root.editing = false;
                        }
                    }
                }
            }
        }
    }

    component ActionButton: Button {
        id: button
        implicitHeight: 30
        implicitWidth: Math.max(30, contentItem.implicitWidth + 16)
        contentItem: Text {
            text: button.text
            color: button.enabled ? Theme.text : Theme.muted
            font.family: Theme.fontMain
            font.pixelSize: Theme.fontSizeSm
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: button.down ? Theme.accent : (button.hovered ? Theme.surface2 : Theme.surface0)
            border.width: button.activeFocus ? 1 : 0
            border.color: Theme.accent
            radius: Theme.radiusAlt
        }
    }
}
