import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    id: gpuData

    property real gpuUsage: 0
    property real gpuTemp: 0
    property real vramUsed: 0
    property real vramTotal: 1
    property real vramUsage: 0
    property Process nvidiaProcess

    nvidiaProcess: Process {
        running: true
        command: ["nvidia-smi", "dmon", "-s", "pu", "-d", "2"]

        stdout: SplitParser {
            onRead: (line) => {
                if (line.startsWith("#") || line.trim() === "")
                    return ;

                let parts = line.trim().split(/\s+/);
                if (parts.length >= 4) {
                    gpuData.gpuUsage = parseFloat(parts[1]) || 0;
                    gpuData.gpuTemp = parseFloat(parts[3]) || 0;
                }
            }
        }

    }

    property Process vramProcess

    vramProcess: Process {
        running: true
        command: ["nvidia-smi", "--query-gpu=memory.used,memory.total", "--format=csv,noheader,nounits", "-l", "2"]

        stdout: SplitParser {
            onRead: (line) => {
                if (line.trim() === "")
                    return ;

                let parts = line.split(",").map((v) => {
                    return parseFloat(v.trim());
                });
                if (parts.length >= 2 && !isNaN(parts[0])) {
                    gpuData.vramUsed = parts[0] / 1024;
                    gpuData.vramTotal = parts[1] / 1024;
                    gpuData.vramUsage = (parts[0] / parts[1]) * 100;
                }
            }
        }

    }

}
