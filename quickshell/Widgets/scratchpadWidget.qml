import ".."
import QtQuick
import QtQuick.Controls

BaseWidget {
    id: root

    widgetId: "scratchpad"
    widgetWidth: 520
    widgetHeight: 420
    // Only request native keyboard focus while the pointer is in the popup.
    // Taking focus during the module's opening click disrupts subsequent clicks.
    property bool pointerInside: false
    focusable: visible && pointerInside
    property string draft: DBService.scratchpadText
    property bool dirty: false

    function saveNote() {
        if (dirty && DBService.saveScratchpad(draft))
            dirty = false;
    }

    onVisibleChanged: {
        if (!visible)
            pointerInside = false;
        if (!visible)
            saveNote();
    }

    widgetComponent: Rectangle {
        HoverHandler {
            onHoveredChanged: root.pointerInside = hovered
        }

        color: Theme.base
        radius: Theme.radius
        border.width: 3
        border.color: Theme.accent

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Text {
                text: "Scratchpad"
                color: Theme.text
                font.family: Theme.fontMain
                font.pixelSize: Theme.fontSizeLg
                font.bold: true
            }

            ScrollView {
                width: parent.width
                height: parent.height - 76
                clip: true

                TextArea {
                    objectName: "scratchpadEditor"
                    text: root.draft
                    enabled: DBService.ready
                    placeholderText: "Write a quick note…"
                    wrapMode: TextEdit.Wrap
                    color: Theme.text
                    placeholderTextColor: Theme.subtext1
                    selectionColor: Theme.accent
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeBase
                    background: Rectangle { color: Theme.surface1; radius: Theme.radiusAlt }
                    Component.onCompleted: forceActiveFocus()
                    onTextChanged: {
                        if (activeFocus && text !== root.draft) {
                            root.draft = text;
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
        }
    }
}
