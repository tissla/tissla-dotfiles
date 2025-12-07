// Gpu/GpuDataProvider.qml
import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    id: gpuData

    // GPU Data properties
    property real gpuUsage: 0
    property real gpuTemp: 0
    property real vramUsed: 0
    property real vramTotal: 1
    property real vramUsage: 0
    property string gpuVendor: "unknown"
    // Detection state
    property bool isDetected: false
    property bool isRunning: false
    property Process detectProcess
    property Timer updateTimer
    property Process nvidiaProcess
    property Process amdProcess

    function detectGpuVendor() {
        detectProcess.running = true;
    }

    function startPolling() {
        if (!isDetected) {
            console.log("[GpuDataProvider] GPU not detected, cannot start polling");
            return ;
        }
        isRunning = true;
        updateTimer.start();
    }

    function stopPolling() {
        isRunning = false;
        updateTimer.stop();
    }

    Component.onCompleted: {
        console.log("[GpuDataProvider] Initializing...");
        detectGpuVendor();
    }

    detectProcess: Process {
        running: false
        command: ["sh", "-c", "lspci | grep -i 'vga\\|3d\\|display'"]

        stdout: StdioCollector {
            onStreamFinished: {
                let output = text.toLowerCase();
                if (output.includes("nvidia")) {
                    gpuData.gpuVendor = "nvidia";
                    gpuData.isDetected = true;
                    console.log("[GpuDataProvider] Detected NVIDIA GPU");
                } else if (output.includes("amd") || output.includes("radeon")) {
                    gpuData.gpuVendor = "amd";
                    gpuData.isDetected = true;
                    console.log("[GpuDataProvider] Detected AMD GPU");
                } else if (output.includes("intel")) {
                    gpuData.gpuVendor = "intel";
                    gpuData.isDetected = true;
                    console.log("[GpuDataProvider] Detected Intel GPU");
                } else {
                    console.log("[GpuDataProvider] Unknown GPU vendor");
                }
                if (gpuData.isDetected)
                    startPolling();

            }
        }

    }

    updateTimer: Timer {
        interval: 2000
        running: false
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (gpuData.gpuVendor === "nvidia")
                nvidiaProcess.running = true;
            else if (gpuData.gpuVendor === "amd")
                amdProcess.running = true;
        }
    }

    nvidiaProcess: Process {
        running: false
        command: ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total", "--format=csv,noheader,nounits"]

        stdout: StdioCollector {
            onStreamFinished: {
                let values = text.trim().split(",").map((v) => {
                    return parseFloat(v.trim());
                });
                if (values.length >= 4 && !isNaN(values[0])) {
                    gpuData.gpuUsage = values[0];
                    gpuData.gpuTemp = values[1];
                    gpuData.vramUsed = values[2] / 1024;
                    gpuData.vramTotal = values[3] / 1024;
                    gpuData.vramUsage = (values[2] / values[3]) * 100;
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0)
                    console.log("[GpuDataProvider] NVIDIA error:", text);

            }
        }

    }

    amdProcess: Process {
        running: false
        command: ["sh", "-c", "if command -v rocm-smi >/dev/null 2>&1; then " + "  rocm-smi --showuse --showtemp --showmeminfo vram | grep -E 'GPU use|Temperature|VRAM Total|VRAM Used'; " + "else " + "  echo 'GPU: 0%'; " + "  cat /sys/class/drm/card*/device/hwmon/hwmon*/temp1_input 2>/dev/null | head -1; " + "  echo 'VRAM: 0 / 0'; " + "fi"]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n");
                for (let line of lines) {
                    if (line.includes("GPU use")) {
                        let match = line.match(/(\d+)%/);
                        if (match)
                            gpuData.gpuUsage = parseFloat(match[1]);

                    } else if (line.includes("Temperature")) {
                        let match = line.match(/([\d.]+)/);
                        if (match)
                            gpuData.gpuTemp = parseFloat(match[1]);

                    } else if (line.includes("VRAM")) {
                        let match = line.match(/([\d.]+)\s*\/\s*([\d.]+)/);
                        if (match) {
                            gpuData.vramUsed = parseFloat(match[1]);
                            gpuData.vramTotal = parseFloat(match[2]);
                            gpuData.vramUsage = (gpuData.vramUsed / gpuData.vramTotal) * 100;
                        }
                    }
                }
            }
        }

    }

}
