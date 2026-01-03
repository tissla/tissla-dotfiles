import "../.."
import QtQuick
import Quickshell.Io

// TODO: find better solution
BaseModule {
    id: vpnModule

    property bool vpnConnected: false
    // hard coded for now
    property string vpnCheck: "https://am.i.mullvad.net/json"

    moduleText: ""
    moduleIcon: {
        if (vpnConnected)
            return "󰖂";

        return "󰕑";
    }

    Timer {
        running: true
        repeat: true
        interval: 5000
        triggeredOnStart: true
        onTriggered: {
            vpnStatusProcess.running = true;
        }
    }

    Process {
        id: vpnStatusProcess

        running: false
        command: ["curl", vpnModule.vpnCheck]

        stdout: StdioCollector {
            onStreamFinished: {
                let data = JSON.parse(text);
                if (data.mullvad_exit_ip && data.mullvad_exit_ip === true)
                    vpnModule.vpnConnected = true;
                else
                    vpnModule.vpnConnected = false;
            }
        }

    }

}
