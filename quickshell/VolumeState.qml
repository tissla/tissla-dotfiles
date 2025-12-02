// VolumeState.qml
import QtQuick
pragma Singleton

QtObject {
    id: root

    property bool isVisible: false

    function toggle() {
        isVisible = !isVisible;
    }

    function show() {
        isVisible = true;
    }

    function hide() {
        isVisible = false;
    }

}
