import QtQuick
import QtTest
import "."

TestCase {
    name: "Lifetimes"
    when: windowShown
    width: 1600
    height: 600
    visible: true
    QtObject { id: screenOne; property string name: "one"; property int x: 0; property int width: 1920; property int height: 1080 }
    QtObject { id: screenTwo; property string name: "two"; property int x: 1920; property int width: 1920; property int height: 1080 }
    QtObject {
        id: lockContext
        property bool unlockInProgress: false
        property string currentText: ""
        property bool showFailure: false
        property bool authPending: false
    }
    Component { id: lockFactory; LockSurface { context: lockContext; screen: screenOne } }
    Component { id: themeFactory; ThemeWidget {} }
    Component { id: cpuFactory; CpuModule {} }
    Component { id: devicesFactory; DevicesModule {} }

    function test_module_destruction() {
        const cpuOne = cpuFactory.createObject(this);
        const cpuTwo = cpuFactory.createObject(this);
        verify(cpuOne !== null && cpuTwo !== null);
        compare(PerformanceDataProvider.consumers.length, 2);
        cpuOne.destroy();
        wait(0);
        verify(PerformanceDataProvider.cpuProcess.running);
        cpuTwo.destroy();
        wait(0);
        verify(!PerformanceDataProvider.cpuProcess.running);
        compare(PerformanceDataProvider.consumers.length, 0);
        verify(!WidgetManager.moduleRegistry.cpu);

        const device = devicesFactory.createObject(this);
        verify(device !== null);
        verify(DevicesDataProvider.isActive);
        device.destroy();
        wait(0);
        verify(!DevicesDataProvider.isActive);
        verify(!WidgetManager.moduleRegistry.devices);
    }

    function test_lock_connections_destroyed() {
        failOnWarning(/ReferenceError|TypeError/);
        for (let i = 0; i < 10; i++) {
            ignoreWarning(/QML Column: Cannot specify/);
            let surface = lockFactory.createObject(this);
            verify(surface !== null);
            surface.destroy();
            wait(0);
        }
        gc();
        WeatherDataProvider.weatherDataReady([{ temp: 10, icon: "", wText: "Clear", latestUpdate: new Date() }]);
        wait(0);
    }

    function test_wallpaper_virtualization() {
        WallpaperManager.availableWallpapers = Array(100).fill("large.svg");
        const wrapper = createTemporaryObject(themeFactory, this);
        verify(wrapper !== null);
        const content = wrapper.widgetComponent.createObject(this, { width: 1400, height: 400 });
        verify(content !== null);
        const list = findChild(content, "wallpaperList");
        verify(list !== null);
        tryVerify(() => list.contentItem.children.length > 1);
        tryVerify(() => list.contentItem.children.length < 20, 1000, "Must not instantiate all 100 previews");
        const image = findChild(content, "wallpaperImage");
        verify(image !== null);
        tryCompare(image, "status", Image.Ready);
        verify(image.sourceSize.width < 1000, "Decode thumbnail, not 4000px original");
        list.positionViewAtEnd();
        wait(30);
        verify(list.contentItem.children.length < 20);
        content.destroy();
        WallpaperManager.availableWallpapers = [];
    }

    function test_widget_ids() {
        compare(WidgetManager.widgetIdsForModules(["cpu", "audiowave", "cpu", "theme", "workspaces", "systemtray"]), ["cpu", "theme"]);
    }

    function test_screen_routing() {
        Quickshell.screens = [screenOne, screenTwo];
        const widget = createTemporaryObject(widgetFactory, this);
        WidgetManager.setMousePosition(Qt.point(300, 0), screenOne);
        WidgetManager.toggleWidget("test");
        verify(widget.visible);
        compare(widget.screen, screenOne);
        compare(widget.visibilityChanges, 1);
        WidgetManager.setMousePosition(Qt.point(2200, 0), screenTwo);
        WidgetManager.toggleWidget("test");
        verify(widget.visible);
        compare(widget.screen, screenTwo);
        WidgetManager.toggleWidget("test");
        verify(!widget.visible);
        Quickshell.screens = [];
    }
    QtObject { id: first }
    QtObject { id: second }

    Component {
        id: widgetFactory
        BaseWidget {
            property int visibilityChanges: 0
            onVisibleChanged: visibilityChanges++
            widgetId: "test"
            widgetWidth: 100
            widgetHeight: 100
            widgetComponent: Item { objectName: "loadedContents" }
        }
    }

    function test_widget_unloads() {
        const widget = createTemporaryObject(widgetFactory, this);
        verify(widget !== null);
        verify(findChild(widget, "loadedContents") === null, "Hidden widget must start unloaded");
        widget.visible = true;
        tryVerify(() => findChild(widget, "loadedContents") !== null);
        widget.visible = false;
        tryVerify(() => findChild(widget, "loadedContents") === null);
        widget.visible = true;
        tryVerify(() => findChild(widget, "loadedContents") !== null);
    }

    function test_cpu_consumers() {
        const p = PerformanceDataProvider;
        p.startPolling(first);
        p.startPolling(first);
        p.startPolling(second);
        verify(p.cpuProcess.running);
        verify(!p.ramProcess.running, "Bar must not poll widget-only RAM data");
        p.stopPolling(first);
        verify(p.cpuProcess.running, "Second bar still needs CPU data");
        p.stopPolling(second);
        verify(!p.cpuProcess.running, "Last consumer must stop CPU polling");
    }

    function test_details_consumers() {
        const p = PerformanceDataProvider;
        p.startDetails(first);
        verify(p.cpuProcess.running);
        verify(p.ramProcess.running);
        verify(p.sensorsProcess.running);
        p.stopDetails(first);
        verify(!p.cpuProcess.running);
        verify(!p.ramProcess.running);
        verify(!p.sensorsProcess.running);
    }

    function test_devices_reactivation() {
        const p = DevicesDataProvider;
        p.activate(first);
        p.controllerConnected = true;
        p.controllerBattery = 75;
        p.deactivate(first);
        p.activate(first);
        verify(!p.controllerConnected, "Reactivation must not reuse a stale connection");
        compare(p.controllerBattery, 0);
        p.deactivate(first);
    }

    function test_devices_consumers() {
        const p = DevicesDataProvider;
        p.activate(first);
        p.activate(first);
        p.activate(second);
        p.deactivate(first);
        verify(p.btMonitorProcess.running, "Second bar still needs device events");
        p.deactivate(second);
        verify(!p.btMonitorProcess.running);
        verify(!p.lsusbTimer.running);
        verify(!p.initialFetchProcess.running);
        verify(!p.lsusbProcess.running);
    }

    function test_registry_duplicates() {
        const m = WidgetManager;
        m.registerModule("battery", first);
        m.registerModule("battery", first);
        compare(m.moduleRegistry.battery.length, 1);
        m.unregisterModule("battery", first);
        verify(!m.moduleRegistry.battery);
    }
}
