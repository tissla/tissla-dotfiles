pragma ComponentBehavior: Bound

import ".."
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell

BaseWidget {
    id: root
    widgetId: "theme"
    centered: true
    widgetWidth: Math.min(1120, screen ? screen.width - 40 : 1120)
    widgetHeight: Math.min(620, screen ? screen.height - 80 : 620)
    focusable: panelHover.hovered

    HoverHandler {
        id: panelHover
    }

    widgetComponent: Rectangle {
        id: panel
        property real terminalOpacityDraft: 0.85
        property bool terminalBlurDraft: false
        readonly property bool terminalSettingsChanged: Math.abs(terminalOpacityDraft - SettingsManager.terminalOpacity) > 0.005
            || terminalBlurDraft !== SettingsManager.terminalBlur
        property string selectedScreen: root.screen ? root.screen.name : ""
        readonly property string currentWallpaper: WallpaperManager.wallpapers[selectedScreen] || ""

        function applyWallpaper(filename) {
            if (!selectedScreen || !filename)
                return;
            const configs = Object.assign({}, SettingsManager.screenConfigs);
            const existing = configs[selectedScreen] || {
                left: ["workspaces"],
                center: [],
                right: []
            };
            configs[selectedScreen] = Object.assign({}, existing, {
                wallpaper: filename
            });
            SettingsManager.screenConfigs = configs;
            SettingsManager.saveSettings();
        }

        function revealCurrent() {
            const index = WallpaperManager.availableWallpapers.indexOf(currentWallpaper);
            if (index >= 0) {
                wallpaperScroll.currentIndex = index;
                wallpaperScroll.positionViewAtIndex(index, ListView.Center);
            }
        }

        onSelectedScreenChanged: Qt.callLater(revealCurrent)
        Component.onCompleted: {
            terminalOpacityDraft = SettingsManager.terminalOpacity;
            terminalBlurDraft = SettingsManager.terminalBlur;
            // Establish item focus through the Loader; the window still only
            // accepts keyboard focus while the pointer is inside it.
            forceActiveFocus();
            Qt.callLater(revealCurrent);
        }
        color: Theme.baseSolid
        radius: 20
        border.width: 1
        border.color: Theme.overlay0
        focus: true
        Keys.onEscapePressed: root.visible = false
        Keys.onLeftPressed: wallpaperScroll.decrementCurrentIndex()
        Keys.onRightPressed: wallpaperScroll.incrementCurrentIndex()
        Keys.onReturnPressed: {
            if (wallpaperScroll.currentIndex >= 0)
                applyWallpaper(WallpaperManager.availableWallpapers[wallpaperScroll.currentIndex]);
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    spacing: 3
                    Text {
                        text: "Themes & Wallpapers"
                        font.family: Theme.fontMain
                        font.pixelSize: 26
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
                Rectangle {
                    implicitWidth: 8
                    implicitHeight: 8
                    radius: 4
                    color: Theme.accent
                }
                Text {
                    text: ThemeManager.activeTheme
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeSm
                    color: Theme.subtext1
                }
                Choice {
                    text: "×"
                    implicitWidth: 36
                    onClicked: root.visible = false
                    Accessible.name: "Close theme picker"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "WALLPAPERS"
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeTiny
                    font.letterSpacing: 1.5
                    font.weight: Font.DemiBold
                    color: Theme.subtext1
                }
                Text {
                    text: WallpaperManager.availableWallpapers.length
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.accent
                }
                Item {
                    Layout.fillWidth: true
                }
                // Keep monitor targets visible, including while moving the pointer.
                Flickable {
                    Layout.preferredWidth: Math.min(screenChoices.implicitWidth, panel.width * 0.55)
                    Layout.preferredHeight: 36
                    contentWidth: screenChoices.implicitWidth
                    contentHeight: height
                    clip: true
                    Row {
                        id: screenChoices
                        spacing: 6
                        Repeater {
                            model: Quickshell.screens
                            Choice {
                                required property var modelData
                                text: modelData.name
                                selected: panel.selectedScreen === modelData.name
                                onClicked: panel.selectedScreen = modelData.name
                            }
                        }
                    }
                }
            }

            ListView {
                id: wallpaperScroll
                objectName: "wallpaperList"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 100
                orientation: ListView.Horizontal
                spacing: 14
                clip: true
                cacheBuffer: 0
                boundsBehavior: Flickable.StopAtBounds
                snapMode: ListView.SnapToItem
                highlightMoveDuration: 180
                model: width > 0 && height > 0 ? WallpaperManager.availableWallpapers : []
                ScrollBar.horizontal: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
                WheelHandler {
                    target: null
                    onWheel: event => {
                        const delta = event.pixelDelta.y || event.pixelDelta.x || event.angleDelta.y || event.angleDelta.x;
                        const maxX = Math.max(0, wallpaperScroll.contentWidth - wallpaperScroll.width);
                        wallpaperScroll.contentX = wallpaperScroll.originX + Math.max(0, Math.min(maxX, wallpaperScroll.contentX - wallpaperScroll.originX - delta));
                        event.accepted = true;
                    }
                }
                delegate: Rectangle {
                    id: card
                    objectName: "wallpaperPreview"
                    required property string modelData
                    required property int index
                    readonly property bool applied: panel.currentWallpaper === modelData
                    width: Math.min(380, wallpaperScroll.width * 0.82)
                    height: Math.max(1, wallpaperScroll.height - 12)
                    radius: 12
                    color: cardHover.hovered ? Theme.surface1 : Theme.surface0
                    border.width: applied ? 2 : 1
                    border.color: applied ? Theme.accent : cardHover.hovered || ListView.isCurrentItem ? Theme.overlay1 : Theme.surface2
                    Behavior on color {
                        ColorAnimation {
                            duration: 140
                        }
                    }

                    Image {
                        id: wallpaperImage
                        objectName: "wallpaperImage"
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 7
                        }
                        height: Math.max(1, parent.height - 62)
                        source: WallpaperManager.wallpapersPath + "/" + card.modelData
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: Math.max(1, Math.ceil(width * Screen.devicePixelRatio))
                        sourceSize.height: Math.max(1, Math.ceil(height * Screen.devicePixelRatio))
                        cache: false
                    }
                    Text {
                        anchors.centerIn: wallpaperImage
                        visible: wallpaperImage.status === Image.Error
                        text: "Preview unavailable"
                        color: Theme.subtext1
                        font.family: Theme.fontMain
                    }
                    RowLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                            margins: 14
                        }
                        spacing: 8
                        Text {
                            Layout.fillWidth: true
                            text: ""
                            elide: Text.ElideRight
                            font.family: Theme.fontMain
                            font.pixelSize: Theme.fontSizeSm
                            color: Theme.text
                        }
                        Text {
                            text: card.applied ? "✓ Active" : "Apply ↗"
                            font.family: Theme.fontMain
                            font.pixelSize: Theme.fontSizeXs
                            color: card.applied ? Theme.accent : Theme.subtext1
                        }
                    }
                    HoverHandler {
                        id: cardHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: {
                            wallpaperScroll.currentIndex = card.index;
                            panel.applyWallpaper(card.modelData);
                        }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    visible: wallpaperScroll.count === 0
                    text: "No wallpapers found in your wallpaper folder."
                    color: Theme.subtext1
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeSm
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.surface2
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "PALETTE"
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeTiny
                    font.letterSpacing: 1.5
                    font.weight: Font.DemiBold
                    color: Theme.subtext1
                }
                Item {
                    Layout.fillWidth: true
                }
            }
            ListView {
                id: themeScroll
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                orientation: ListView.Horizontal
                spacing: 8
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: ThemeManager.availableThemes
                delegate: Choice {
                    required property string modelData
                    text: modelData === "matugen" ? "✦ Wallpaper colors" : modelData.replace(/^tissla-/, "").replace(/-/g, " ")
                    selected: ThemeManager.activeTheme === modelData
                    onClicked: ThemeManager.setTheme(modelData)
                }
                WheelHandler {
                    target: null
                    onWheel: event => {
                        const delta = event.pixelDelta.y || event.pixelDelta.x || event.angleDelta.y || event.angleDelta.x;
                        const maxX = Math.max(0, themeScroll.contentWidth - themeScroll.width);
                        themeScroll.contentX = themeScroll.originX + Math.max(0, Math.min(maxX, themeScroll.contentX - themeScroll.originX - delta));
                        event.accepted = true;
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Theme.surface2
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 14
                Text {
                    text: "TERMINAL"
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeTiny
                    font.letterSpacing: 1.5
                    font.weight: Font.DemiBold
                    color: Theme.subtext1
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "Opacity"
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeSm
                    color: Theme.text
                }
                Slider {
                    id: terminalOpacity
                    objectName: "terminalOpacity"
                    Layout.preferredWidth: Math.min(220, panel.width * 0.25)
                    from: 0
                    to: 1
                    stepSize: 0.01
                    Accessible.name: "Alacritty opacity"
                    value: panel.terminalOpacityDraft
                    onMoved: panel.terminalOpacityDraft = value
                    background: Rectangle {
                        x: terminalOpacity.leftPadding
                        y: terminalOpacity.topPadding + terminalOpacity.availableHeight / 2 - height / 2
                        width: terminalOpacity.availableWidth
                        implicitHeight: 4
                        height: 4
                        radius: 2
                        color: Theme.surface2
                        Rectangle {
                            width: terminalOpacity.visualPosition * parent.width
                            height: parent.height
                            radius: 2
                            color: Theme.accent
                        }
                    }
                    handle: Rectangle {
                        x: terminalOpacity.leftPadding + terminalOpacity.visualPosition * (terminalOpacity.availableWidth - width)
                        y: terminalOpacity.topPadding + terminalOpacity.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        color: terminalOpacity.enabled ? Theme.accent : Theme.overlay0
                    }
                }
                Text {
                    Layout.preferredWidth: 42
                    text: Math.round(terminalOpacity.value * 100) + "%"
                    horizontalAlignment: Text.AlignRight
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSm
                    color: Theme.text
                }
                CheckBox {
                    id: terminalBlur
                    objectName: "terminalBlur"
                    text: "Blur"
                    checked: panel.terminalBlurDraft
                    onToggled: panel.terminalBlurDraft = checked
                    implicitHeight: 36
                    Accessible.name: "Hyprland terminal blur"
                    indicator: Rectangle {
                        implicitWidth: 18
                        implicitHeight: 18
                        x: terminalBlur.leftPadding
                        y: (terminalBlur.height - height) / 2
                        radius: 4
                        color: terminalBlur.checked ? Theme.accent : Theme.surface0
                        border.width: 1
                        border.color: terminalBlur.checked ? Theme.accent : Theme.overlay1
                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            visible: terminalBlur.checked
                            color: Theme.baseSolid
                            font.pixelSize: 14
                        }
                    }
                    contentItem: Text {
                        text: terminalBlur.text
                        leftPadding: terminalBlur.indicator.width + terminalBlur.spacing
                        verticalAlignment: Text.AlignVCenter
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        color: Theme.text
                    }
                }
                Choice {
                    objectName: "terminalApply"
                    text: SettingsManager.terminalSettingsBusy ? "Applying…" : "Apply"
                    selected: enabled
                    enabled: !SettingsManager.terminalSettingsBusy
                        && (panel.terminalSettingsChanged || SettingsManager.terminalSettingsError !== "")
                    onClicked: SettingsManager.setTerminalAppearance(panel.terminalOpacityDraft, panel.terminalBlurDraft)
                }
            }
            Text {
                Layout.fillWidth: true
                visible: SettingsManager.terminalSettingsError !== ""
                text: SettingsManager.terminalSettingsError
                font.family: Theme.fontMain
                font.pixelSize: Theme.fontSizeXs
                color: Theme.red
            }


        }
    }

    component Choice: Button {
        id: control
        property bool selected: false
        implicitHeight: 36
        implicitWidth: label.implicitWidth + 28
        padding: 0
        hoverEnabled: true
        focusPolicy: Qt.NoFocus
        contentItem: Text {
            id: label
            text: control.text
            font.family: Theme.fontMain
            font.pixelSize: Theme.fontSizeSm
            font.weight: control.selected ? Font.DemiBold : Font.Normal
            color: control.selected ? Theme.baseSolid : Theme.text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 10
            color: control.selected ? Theme.accent : control.hovered ? Theme.surface2 : Theme.surface0
            border.width: control.selected ? 0 : 1
            border.color: Theme.surface2
            Behavior on color {
                ColorAnimation {
                    duration: 140
                }
            }
        }
    }
}
