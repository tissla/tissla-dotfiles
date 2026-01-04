import ".."
import QtQuick
import QtQuick.Controls
import Quickshell

BaseWidget {
    widgetId: "theme"
    widgetWidth: 1400
    widgetHeight: 400

    widgetComponent: Rectangle {
        color: Theme.background
        radius: Theme.radius
        border.width: Theme.borderWidth
        border.color: Theme.primary

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
                    color: Theme.foreground
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
                        ScrollBar.horizontal.contentItem.color = Theme.surface;
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
                                color: Theme.surface

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
                                    id: screenRow

                                    property bool isVisible

                                    visible: isVisible
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: Theme.spacingMd
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    radius: Theme.radiusAlt
                                    color: Theme.background
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
                                                    if (SettingsManager.wallpapers[index] === wallpaperRect.wpFilename)
                                                        return Theme.primary;

                                                    if (screenMouse.containsMouse)
                                                        return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2);

                                                    return Theme.surface;
                                                }

                                                Text {
                                                    visible: parent.visible
                                                    text: index + 1
                                                    font.pixelSize: Theme.fontSizeSm
                                                    font.family: Theme.fontMain
                                                    font.weight: Font.Bold
                                                    color: Theme.foregroundAlt
                                                    anchors.centerIn: parent
                                                }

                                                MouseArea {
                                                    id: screenMouse

                                                    anchors.fill: parent
                                                    preventStealing: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        // mutate the whole array to trigger propertychange
                                                        let newWallpapers = SettingsManager.wallpapers.slice();
                                                        newWallpapers[index] = wallpaperRect.wpFilename;
                                                        SettingsManager.wallpapers = newWallpapers;
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
                    color: Theme.foreground
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
                                    return Theme.primary;

                                if (mouseArea.containsMouse)
                                    return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.5);

                                return Theme.surface;
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
                                    color: modelData === ThemeManager.activeTheme ? Theme.backgroundSolid : Theme.foreground
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Active indicator
                                Text {
                                    visible: modelData === ThemeManager.activeTheme
                                    text: "✓"
                                    font.pixelSize: Theme.fontSizeLg
                                    color: Theme.backgroundSolid
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
