pragma Singleton

QtObject {
    function createState() {
        return Qt.createQmlObject(`
            import QtQuick
            QtObject {
                property bool isVisible: false
                function toggle() { isVisible = !isVisible }
                function show() { isVisible = true }
                function hide() { isVisible = false }
            }
        `, this);
    }

}
