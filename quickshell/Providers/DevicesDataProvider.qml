pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

QtObject {
    id: root

    property bool monitoringEnabled: true
    property var consumers: []
    readonly property bool isActive: monitoringEnabled && consumers.length > 0
    property var hardwareDevices: []
    property var bluetoothDevices: Bluetooth.devices.values
    property string errorMessage: ""
    property bool refreshPending: false
    readonly property bool refreshing: snapshotProcess.running
    readonly property var devices: mergeDevices(hardwareDevices, bluetoothDevices)
    readonly property int connectedCount: devices.length
    readonly property int lowBatteryCount: devices.filter(d => d.battery !== null && d.battery <= 20 && !d.charging).length
    readonly property int lowestBattery: {
        const levels = devices.filter(d => d.battery !== null && !d.charging).map(d => d.battery);
        return levels.length ? Math.min.apply(null, levels) : -1;
    }

    function activate(owner) {
        if (consumers.indexOf(owner) === -1)
            consumers = consumers.concat([owner]);
    }

    function deactivate(owner) {
        consumers = consumers.filter(item => item !== owner);
    }

    function kindForIcon(icon) {
        if (/gaming|gamepad|joystick/.test(icon)) return "controller";
        if (/tablet|touchscreen/.test(icon)) return "tablet";
        if (/touchpad/.test(icon)) return "touchpad";
        if (/keyboard/.test(icon)) return "keyboard";
        if (/mouse/.test(icon)) return "mouse";
        if (/audio|headset|headphone/.test(icon)) return "audio";
        if (/camera|video/.test(icon)) return "camera";
        return "device";
    }

    function typeLabel(kind) {
        return ({controller: "Controller", keyboard: "Keyboard", mouse: "Mouse", tablet: "Tablet",
            touchpad: "Touchpad", audio: "Audio", camera: "Camera", device: "Device"})[kind] || "Device";
    }

    function iconFor(kind) {
        return ({controller: "󰊴", keyboard: "󰌌", mouse: "󰍽", tablet: "󰓶", touchpad: "󰟸",
            audio: "󰋋", camera: "󰄀", device: "󰇄"})[kind] || "󰇄";
    }

    function batteryPercent(value) {
        return typeof value === "number" && Number.isFinite(value) && value >= 0 && value <= 100 ? Math.round(value) : null;
    }

    function mergeDevices(hardware, bluetooth) {
        const known = {};
        const rows = {};
        for (const device of bluetooth) {
            if (device) known[device.address.toLowerCase()] = device;
        }
        for (const device of hardware) {
            const address = (device.address || "").toLowerCase();
            // BlueZ reports disconnects before the corresponding input node disappears.
            if (device.transport === "Bluetooth" && known[address] && !known[address].connected)
                continue;
            rows[device.id] = Object.assign({}, device, {address: address, battery: batteryPercent(device.battery)});
        }
        for (const device of bluetooth) {
            if (!device || !device.connected || /^(phone|computer|network)/.test(device.icon))
                continue;
            const address = device.address.toLowerCase();
            const previous = Object.values(rows).find(d => d.transport === "Bluetooth" && d.address === address);
            const id = previous ? previous.id : "bluetooth:" + address;
            const kind = kindForIcon(device.icon);
            rows[id] = {
                id: id, address: address, name: device.name || device.deviceName || address,
                kind: kind === "device" && previous ? previous.kind : kind,
                transport: "Bluetooth",
                battery: device.batteryAvailable ? batteryPercent(device.battery * 100) : previous ? previous.battery : null,
                charging: previous ? previous.charging : false
            };
        }
        const order = ["controller", "keyboard", "mouse", "touchpad", "tablet", "audio", "camera", "device"];
        return Object.values(rows).sort((a, b) => order.indexOf(a.kind) - order.indexOf(b.kind)
            || a.name.localeCompare(b.name) || a.id.localeCompare(b.id));
    }

    function acceptSnapshot(text, exitCode, exitStatus) {
        try {
            if (exitCode !== 0 || exitStatus !== 0) throw new Error("discovery failed");
            const parsed = JSON.parse(text);
            if (!Array.isArray(parsed) || !parsed.every(d => d && typeof d.id === "string"
                && typeof d.name === "string" && typeof d.kind === "string"
                && ["USB", "Bluetooth"].indexOf(d.transport) !== -1))
                throw new Error("invalid snapshot");
            hardwareDevices = parsed;
            errorMessage = "";
        } catch (error) {
            hardwareDevices = [];
            errorMessage = "USB device information unavailable";
        }
    }

    function refresh() {
        if (!isActive) return;
        if (snapshotProcess.running) {
            refreshPending = true;
            return;
        }
        refreshPending = false;
        snapshotProcess.running = true;
    }

    onIsActiveChanged: {
        if (isActive) {
            refresh();
            monitorProcess.running = true;
        } else {
            debounce.stop();
            refreshPending = false;
            snapshotProcess.running = false;
            monitorProcess.running = false;
            hardwareDevices = [];
        }
    }

    property Process snapshotProcess: Process {
        command: ["python3", Quickshell.shellPath("Providers/devices-snapshot.py")]
        stdout: StdioCollector { id: snapshotOutput }
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            if (!root.isActive) return;
            root.acceptSnapshot(snapshotOutput.text, exitCode, exitStatus);
            if (root.refreshPending) root.refresh();
        }
    }

    property Process monitorProcess: Process {
        command: ["udevadm", "monitor", "--udev", "--subsystem-match=input", "--subsystem-match=sound",
            "--subsystem-match=video4linux", "--subsystem-match=power_supply"]
        stdout: SplitParser {
            onRead: line => { if (line.startsWith("UDEV") && root.isActive) root.debounce.restart(); }
        }
        stderr: StdioCollector {}
    }

    property Timer debounce: Timer { interval: 250; onTriggered: root.refresh() }
    property Timer periodicRefresh: Timer {
        interval: 30000
        running: root.isActive
        repeat: true
        onTriggered: root.refresh()
    }
    property Timer restartMonitor: Timer {
        interval: 3000
        running: root.isActive && !root.monitorProcess.running
        repeat: true
        onTriggered: { root.monitorProcess.running = true; root.refresh(); }
    }
}
