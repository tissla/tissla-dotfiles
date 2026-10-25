pragma ComponentBehavior: Bound
import ".."
import QtQuick

BaseModule {
    id: kubernetesModule
    widgetId: "kubernetes"
    customContents: true
    customComponent: Component {
        Row {
            spacing: 7
            Rectangle {
                width: 7; height: 7; radius: 4
                anchors.verticalCenter: parent.verticalCenter
                color: kubernetesModule.isPressed ? Theme.baseSolid : KubernetesDataProvider.statusColor
            }
            Text {
                text: "K8s " + (KubernetesDataProvider.errorMessage ? "offline"
                    : !KubernetesDataProvider.serverData ? "…" : KubernetesDataProvider.stale ? "stale"
                    : KubernetesDataProvider.serverData.summary.nodes.ready + "/" + KubernetesDataProvider.serverData.summary.nodes.total)
                    + (KubernetesDataProvider.currentProblems.length && !KubernetesDataProvider.errorMessage && !KubernetesDataProvider.stale
                        ? " · !" + KubernetesDataProvider.currentProblems.length : "")
                font.family: Theme.fontMain
                font.pixelSize: Theme.fontSizeSm
                font.bold: true
                color: kubernetesModule.isPressed ? Theme.baseSolid : Theme.subtext1
            }
        }
    }
}
