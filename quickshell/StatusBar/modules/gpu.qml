import "../.."
import QtQuick
import Quickshell.Io

BaseModule {
    id: gpuModule

    property real gpuUsage: 0

    widgetId: "gpu"
    moduleIcon: "󰢮"
    moduleText: Math.round(gpuModule.gpuUsage) + "%"
    Component.onCompleted: {
        WidgetManager.registerModule(widgetId, this);
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            getGpuProcess.running = true;
        }
    }

    Process {
        id: getGpuProcess

        running: false
        command: ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"]

        stdout: StdioCollector {
            onStreamFinished: {
                let usage = parseFloat(text);
                if (!isNaN(usage))
                    gpuModule.gpuUsage = usage;

            }
        }

    }

}
