import ".."
import QtQuick
import QtQuick.Controls
import Quickshell

BaseWidget {
    widgetId: "theme"
    widgetWidth: 1400
    widgetHeight: 400

    widgetComponent: Rectangle {
        color: Theme.base
        radius: Theme.radius
        border.width: Theme.borderWidth
        border.color: Theme.accent

        Row {
            anchors.fill: parent
            anchors.margins: Theme.spacingLg
            spacing: Theme.spacingLg

            // Wallpaper column
            Column {
                width: parent.width - 250 - Theme.spacingLg
                height: parent.height
                anchors.margins: Theme.spacingLg
                spacing: Theme.spacingMd

                // Header
                Text {
                    id: wpHeader

                    text: "Wallpapers"
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeLg
                    font.weight: Font.Bold
                    color: Theme.text
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // wallpapers
                ScrollView {
                    id: wallpaperScroll

                    width: parent.width
                    height: parent.height - wpHeader.height
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                    contentWidth: wallpaperRow.implicitWidth
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
                    // scrollbar customization
                    Component.onCompleted: {
                        ScrollBar.horizontal.height = 18;
                        ScrollBar.horizontal.contentItem.color = Theme.surface1;
                        ScrollBar.horizontal.contentItem.radius = Theme.radiusAlt;
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        onWheel: (wheel) => {
                            let scrollBar = wallpaperScroll.ScrollBar.horizontal;
                            let delta = wheel.angleDelta.y;
                            let step = delta / 3000;
                            let newPos = Math.max(0, Math.min(1 - scrollBar.size, scrollBar.position - step));
                            scrollBar.position = newPos;
                        }
                    }

                    Row {
                        id: wallpaperRow

                        spacing: Theme.spacingSm
                        topPadding: Theme.spacingMd
                        bottomPadding: Theme.spacingMd

                        Repeater {
                            model: WallpaperManager.availableWallpapers

                            Rectangle {
                                id: wallpaperRect

                                property string wpFilename: modelData

                                height: wallpaperScroll.height - Theme.spacingMd * 2 - 20
                                width: {
                                    if (wallpaperImage.sourceSize.width > 0 && wallpaperImage.sourceSize.height > 0)
                                        return height * (wallpaperImage.sourceSize.width / wallpaperImage.sourceSize.height);

                                    return height;
                                }
                                radius: Theme.radiusAlt
                                color: Theme.surface1

                                Image {
                                    id: wallpaperImage

                                    anchors.fill: parent
                                    anchors.margins: Theme.spacingXs
                                    source: WallpaperManager.wallpapersPath + "/" + modelData
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                }

                                MouseArea {
                                    id: wpRectMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    propagateComposedEvents: true
                                    acceptedButtons: Qt.NoButton
                                    onEntered: screenRow.isVisible = true
                                    onExited: screenRow.isVisible = false
                                }

                                Rectangle {
                                    id: isWpIndicator

                                    property bool isVisible: Object.values(WallpaperManager.wallpapers).indexOf(wallpaperRect.wpFilename) !== -1

                                    visible: isVisible
                                    anchors.top: parent.top
                                    anchors.topMargin: Theme.spacingMd
                                    anchors.right: parent.right
                                    anchors.rightMargin: Theme.spacingLg
                                    color: Theme.base
                                    width: Theme.spacingXl
                                    height: Theme.spacingXl
                                    radius: Theme.radiusAlt

                                    Text {
                                        visible: parent.visible
                                        text: ""
                                        font.pixelSize: Theme.fontSizeSm
                                        font.family: Theme.fontMain
                                        font.weight: Font.Bold
                                        color: Theme.accent
                                        anchors.centerIn: parent
                                    }

                                }

                                Rectangle {
                                    id: screenRow

                                    property bool isVisible

                                    visible: isVisible
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: Theme.spacingMd
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    radius: Theme.radiusAlt
                                    color: Theme.base
                                    width: buttonRow.width + Theme.spacingXs * 2
                                    height: buttonRow.height + Theme.spacingXs * 2

                                    Row {
                                        id: buttonRow

                                        spacing: Theme.spacingXs
                                        padding: Theme.spacingXs
                                        anchors.centerIn: parent

                                        Repeater {
                                            id: wpScreens

                                            model: Quickshell.screens.length

                                            Rectangle {
                                                width: Theme.spacingXl
                                                height: Theme.spacingXl
                                                radius: Theme.radiusAlt
                                                color: {
                                                    if (WallpaperManager.wallpapers[Quickshell.screens[index].name] === wallpaperRect.wpFilename)
                                                        return Theme.accent;

                                                    if (screenMouse.containsMouse)
                                                        return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2);

                                                    return Theme.surface1;
                                                }

                                                Text {
                                                    visible: parent.visible
                                                    text: index + 1
                                                    font.pixelSize: Theme.fontSizeSm
                                                    font.family: Theme.fontMain
                                                    font.weight: Font.Bold
                                                    color: Theme.subtext1
                                                    anchors.centerIn: parent
                                                }

                                                MouseArea {
                                                    id: screenMouse

                                                    anchors.fill: parent
                                                    preventStealing: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        // mutate the whole object to trigger propertychange
                                                        let screenName = Quickshell.screens[index].name;
                                                        let newConfigs = Object.assign({}, SettingsManager.screenConfigs);
                                                        let existing = newConfigs[screenName] || {
                                                            "left": ["workspaces"],
                                                            "center": [],
                                                            "right": []
                                                        };
                                                        newConfigs[screenName] = Object.assign({}, existing, {
                                                            "wallpaper": wallpaperRect.wpFilename
                                                        });
                                                        SettingsManager.screenConfigs = newConfigs;
                                                        SettingsManager.saveSettings();
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

            // Theme column
            Column {
                width: 250
                height: parent.height
                anchors.margins: Theme.spacingLg
                spacing: Theme.spacingMd

                // Header
                Text {
                    text: "Themes"
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeLg
                    font.weight: Font.Bold
                    color: Theme.text
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Theme list
                Column {
                    width: parent.width
                    spacing: Theme.spacingSm

                    Repeater {
                        model: ThemeManager.availableThemes

                        Rectangle {
                            width: parent.width
                            height: 50
                            radius: Theme.radiusAlt
                            color: {
                                if (modelData === ThemeManager.activeTheme)
                                    return Theme.accent;

                                if (mouseArea.containsMouse)
                                    return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5);

                                return Theme.surface1;
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingMd

                                // Theme name
                                Text {
                                    text: modelData
                                    font.family: Theme.fontMain
                                    font.pixelSize: Theme.fontSizeMd
                                    font.weight: Font.Bold
                                    color: modelData === ThemeManager.activeTheme ? Theme.baseSolid : Theme.text
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Active indicator
                                Text {
                                    visible: modelData === ThemeManager.activeTheme
                                    text: "✓"
                                    font.pixelSize: Theme.fontSizeLg
                                    color: Theme.baseSolid
                                    font.weight: Font.Bold
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                            }

                            MouseArea {
                                id: mouseArea

                                preventStealing: true
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    ThemeManager.setTheme(modelData);
                                }
                            }

                        }

                    }

                }

            }

        }

    }

}
