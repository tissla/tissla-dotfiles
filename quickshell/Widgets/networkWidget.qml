pragma ComponentBehavior: Bound

import ".."
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

BaseWidget {
    id: networkWidget

    property string endpoint: "http://192.168.1.240:30099/info"
    readonly property string namespaceFilter: "tissla"
    property var serverData: null
    property string errorMessage: ""
    property double now: Date.now()
    property bool showEvents: false
    property bool showPods: false
    readonly property var sortedPods: serverData ? serverData.pods.slice().sort((a, b) => Number(podHasProblem(b)) - Number(podHasProblem(a)) || a.namespace.localeCompare(b.namespace) || a.name.localeCompare(b.name)) : []
    readonly property int problemPodCount: sortedPods.filter(p => podHasProblem(p)).length
    readonly property int runningPodCount: sortedPods.filter(p => p.phase === "Running" && !podHasProblem(p)).length
    readonly property int completedPodCount: sortedPods.filter(p => p.phase === "Succeeded").length
    onProblemPodCountChanged: {
        if (problemPodCount > 0)
            showPods = true;
    }
    readonly property bool stale: serverData !== null && now - Date.parse(serverData.generatedAt) > 30000
    readonly property bool healthy: serverData !== null && !errorMessage && !stale && serverData.status === "ok" && currentProblems.length === 0
    readonly property string statusText: errorMessage ? "Unavailable" : !serverData ? "Loading…" : stale ? "Stale data" : healthy ? "Healthy" : "Needs attention"
    readonly property color statusColor: errorMessage ? Theme.red : !serverData || stale ? Theme.muted : healthy ? Theme.success : Theme.warning
    readonly property var selectedDeployments: serverData ? serverData.deployments.filter(d => d.namespace === namespaceFilter).sort((a, b) => Number(deploymentReady(a)) - Number(deploymentReady(b)) || a.name.localeCompare(b.name)) : []
    readonly property var currentProblems: serverData ? problemsFor(serverData) : []
    readonly property var recentEvents: serverData ? serverData.events.slice().sort((a, b) => Date.parse(b.lastSeen) - Date.parse(a.lastSeen)) : []

    function deploymentReady(deployment) {
        return deployment.ready >= deployment.desired && deployment.available >= deployment.desired;
    }

    function podHasProblem(pod) {
        if (pod.phase === "Succeeded")
            return false;
        const ready = pod.ready.split("/").map(Number);
        return pod.phase !== "Running" || pod.status !== "Running" || ready[0] < ready[1];
    }

    function podStatus(pod) {
        if (pod.phase === "Succeeded")
            return "Completed";
        return pod.status === "Running" && podHasProblem(pod) ? "Not ready" : pod.status;
    }

    function problemText(problem) {
        if (typeof problem === "string")
            return problem;
        const resource = [problem.namespace, problem.name].filter(Boolean).join("/");
        const message = problem.message || problem.reason || problem.status;
        return message ? (resource ? resource + ": " : "") + message : JSON.stringify(problem);
    }

    function problemsFor(data) {
        if (data.problems.length)
            return data.problems.map(problemText);
        const problems = [];
        for (const node of data.nodes) {
            if (!node.ready)
                problems.push(node.name + ": Not ready");
            if (node.pressure.length)
                problems.push(node.name + ": " + node.pressure.join(", "));
        }
        for (const deployment of data.deployments) {
            if (!deploymentReady(deployment))
                problems.push(deployment.namespace + "/" + deployment.name + ": " + deployment.ready + "/" + deployment.desired + " ready, " + deployment.available + " available");
        }
        for (const pod of data.pods) {
            if (podHasProblem(pod))
                problems.push(pod.namespace + "/" + pod.name + ": " + podStatus(pod) + " (" + pod.ready + " ready)");
        }
        // Preserve summary-level warnings even if a resource is absent from the detail arrays.
        if (!problems.length && (data.summary.nodes.ready < data.summary.nodes.total || data.summary.deployments.available < data.summary.deployments.total || data.summary.pods.pending + data.summary.pods.failed + data.summary.pods.unknown > 0))
            problems.push("Cluster resources are not ready");
        if (!problems.length && data.status !== "ok")
            problems.push("Cluster status: " + data.status);
        return problems;
    }

    function validResponse(data) {
        const count = value => Number.isInteger(value) && value >= 0;
        const group = (value, keys) => value && keys.every(key => count(value[key]));
        return data && typeof data.status === "string" && Number.isFinite(Date.parse(data.generatedAt)) && data.cluster && typeof data.cluster.version === "string" && data.summary && group(data.summary.nodes, ["total", "ready"]) && group(data.summary.deployments, ["total", "available"]) && group(data.summary.pods, ["total", "running", "pending", "succeeded", "failed", "unknown"]) && Array.isArray(data.nodes) && data.nodes.every(n => n && typeof n.name === "string" && typeof n.ready === "boolean" && Array.isArray(n.pressure)) && Array.isArray(data.deployments) && data.deployments.every(d => d && typeof d.namespace === "string" && typeof d.name === "string" && group(d, ["desired", "ready", "available"])) && Array.isArray(data.pods) && data.pods.every(p => p && typeof p.namespace === "string" && typeof p.name === "string" && typeof p.phase === "string" && typeof p.status === "string" && /^\d+\/\d+$/.test(p.ready)) && Array.isArray(data.problems) && data.problems.every(p => p && (typeof p === "string" || typeof p === "object")) && Array.isArray(data.events) && data.events.every(e => e && typeof e.message === "string");
    }

    function fetchServerData() {
        if (!fetchProcess.running)
            fetchProcess.running = true;
    }

    widgetId: "network"
    widgetWidth: Math.min(560, screen ? screen.width - 40 : 560)
    widgetHeight: Math.min(570, screen ? screen.height - 100 : 570)
    onVisibleChanged: {
        if (visible) {
            now = Date.now();
            if (problemPodCount > 0)
                showPods = true;
            fetchServerData();
        }
    }
    Component.onCompleted: {
        if (visible)
            fetchServerData();
    }

    Timer {
        interval: 5000
        running: networkWidget.visible
        repeat: true
        onTriggered: networkWidget.fetchServerData()
    }
    Timer {
        interval: 1000
        running: networkWidget.visible
        repeat: true
        onTriggered: networkWidget.now = Date.now()
    }

    Process {
        id: fetchProcess
        command: ["curl", "--fail", "--silent", "--show-error", "--connect-timeout", "2", "--max-time", "4", networkWidget.endpoint]
        stdout: StdioCollector {
            id: response
        }
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            networkWidget.now = Date.now();
            if (exitCode !== 0 || exitStatus !== 0) {
                networkWidget.errorMessage = "Cannot reach cluster endpoint";
                return;
            }
            try {
                const data = JSON.parse(response.text);
                if (!networkWidget.validResponse(data))
                    throw new Error("Incomplete cluster response");
                networkWidget.serverData = data;
                networkWidget.errorMessage = "";
            } catch (error) {
                networkWidget.errorMessage = "Invalid cluster response";
            }
        }
    }

    widgetComponent: Rectangle {
        color: Theme.baseSolid
        radius: Theme.radius
        border.width: Theme.borderWidth
        border.color: Theme.accent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Kubernetes"
                    font.pixelSize: Theme.fontSizeXl
                    font.bold: true
                    Layout.fillWidth: true
                }
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: networkWidget.statusColor
                }
                Label {
                    text: networkWidget.statusText
                    color: networkWidget.statusColor
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: networkWidget.serverData ? networkWidget.serverData.cluster.version : ""
                    color: Theme.subtext1
                    font.pixelSize: Theme.fontSizeXxs
                    Layout.fillWidth: true
                }
                Label {
                    text: networkWidget.serverData ? "Updated " + Qt.formatDateTime(new Date(networkWidget.serverData.generatedAt), "HH:mm:ss") : ""
                    color: Theme.subtext1
                    font.pixelSize: Theme.fontSizeXxs
                }
            }
            Label {
                Layout.fillWidth: true
                visible: !!networkWidget.errorMessage || networkWidget.stale
                text: networkWidget.errorMessage ? networkWidget.errorMessage + (networkWidget.serverData ? " · showing last response" : "") : "The endpoint is returning an old snapshot"
                color: Theme.warning
                wrapMode: Text.Wrap
            }

            ScrollView {
                id: scroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    width: scroll.availableWidth
                    spacing: 12

                    Label {
                        text: "CLUSTER"
                        color: Theme.subtext1
                        font.pixelSize: Theme.fontSizeXxs
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Metric {
                            title: "NODES READY"
                            value: networkWidget.serverData ? networkWidget.serverData.summary.nodes.ready + "/" + networkWidget.serverData.summary.nodes.total : "—"
                        }
                        Metric {
                            title: "DEPLOYMENTS"
                            value: networkWidget.serverData ? networkWidget.serverData.summary.deployments.available + "/" + networkWidget.serverData.summary.deployments.total : "—"
                        }
                        Metric {
                            title: "PODS"
                            value: networkWidget.serverData ? networkWidget.runningPodCount + " running" : "—"
                            detail: networkWidget.serverData ? networkWidget.completedPodCount + " completed · " + networkWidget.problemPodCount + (networkWidget.problemPodCount === 1 ? " issue" : " issues") : ""
                            detailColor: networkWidget.problemPodCount > 0 ? Theme.warning : Theme.subtext1
                        }
                    }

                    ColumnLayout {
                        visible: networkWidget.currentProblems.length > 0
                        Layout.fillWidth: true
                        spacing: 6
                        Label {
                            text: "PROBLEMS · CLUSTER"
                            color: Theme.warning
                            font.pixelSize: Theme.fontSizeXxs
                        }
                        Repeater {
                            model: networkWidget.currentProblems
                            Label {
                                required property string modelData
                                Layout.fillWidth: true
                                text: modelData
                                wrapMode: Text.Wrap
                                color: Theme.warning
                            }
                        }
                    }

                    Button {
                        id: podsButton
                        Layout.fillWidth: true
                        enabled: networkWidget.serverData !== null
                        onClicked: networkWidget.showPods = !networkWidget.showPods
                        contentItem: Label {
                            text: (networkWidget.showPods ? "▾" : "▸") + " Pods · cluster (" + networkWidget.sortedPods.length + ")"
                            color: networkWidget.problemPodCount > 0 ? Theme.warning : Theme.subtext1
                        }
                        background: Rectangle {
                            color: podsButton.hovered ? Theme.surface2 : "transparent"
                            radius: Theme.radiusAlt
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: networkWidget.showPods
                        spacing: 4
                        Repeater {
                            model: networkWidget.showPods ? networkWidget.sortedPods : []
                            Rectangle {
                                id: podRow
                                required property var modelData
                                readonly property bool hasProblem: networkWidget.podHasProblem(modelData)
                                Layout.fillWidth: true
                                implicitHeight: podContents.implicitHeight + 16
                                color: Theme.surface0
                                radius: Theme.radiusAlt
                                ColumnLayout {
                                    id: podContents
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 3
                                    Label {
                                        Layout.fillWidth: true
                                        text: podRow.modelData.name
                                        wrapMode: Text.WrapAnywhere
                                        color: podRow.hasProblem ? Theme.warning : Theme.text
                                    }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Label {
                                            text: "Namespace: " + podRow.modelData.namespace
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            font.pixelSize: Theme.fontSizeXxs
                                            color: Theme.subtext1
                                        }
                                        Label {
                                            text: networkWidget.podStatus(podRow.modelData)
                                            color: networkWidget.errorMessage || networkWidget.stale ? Theme.muted : podRow.hasProblem ? Theme.warning : podRow.modelData.phase === "Succeeded" ? Theme.subtext1 : Theme.success
                                        }
                                    }
                                    Label {
                                        Layout.fillWidth: true
                                        visible: podRow.modelData.phase !== "Succeeded"
                                        text: podRow.modelData.ready + " ready · " + (podRow.modelData.restarts || 0) + " restarts"
                                        font.pixelSize: Theme.fontSizeXxs
                                        color: Theme.subtext1
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "NAMESPACE"
                            color: Theme.subtext1
                            font.pixelSize: Theme.fontSizeXxs
                        }
                        Label {
                            text: networkWidget.namespaceFilter
                            color: Theme.accent
                            font.bold: true
                            Layout.fillWidth: true
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "DEPLOYMENTS"
                            font.pixelSize: Theme.fontSizeXxs
                            color: Theme.subtext1
                            Layout.fillWidth: true
                        }
                        Label {
                            text: "READY"
                            Layout.preferredWidth: 64
                            horizontalAlignment: Text.AlignRight
                            color: Theme.subtext1
                            font.pixelSize: Theme.fontSizeXxs
                        }
                        Label {
                            text: "UPTIME"
                            Layout.preferredWidth: 80
                            horizontalAlignment: Text.AlignRight
                            color: Theme.subtext1
                            font.pixelSize: Theme.fontSizeXxs
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Repeater {
                            model: networkWidget.selectedDeployments
                            Rectangle {
                                id: deploymentRow
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 32
                                color: Theme.surface0
                                radius: Theme.radiusAlt
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 8
                                    spacing: 8
                                    Rectangle {
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: networkWidget.errorMessage || networkWidget.stale || deploymentRow.modelData.desired === 0 ? Theme.muted : networkWidget.deploymentReady(deploymentRow.modelData) ? Theme.success : Theme.warning
                                    }
                                    Label {
                                        text: deploymentRow.modelData.name
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                    Label {
                                        text: deploymentRow.modelData.ready + "/" + deploymentRow.modelData.desired
                                        Layout.preferredWidth: 48
                                        horizontalAlignment: Text.AlignRight
                                    }
                                    Label {
                                        text: deploymentRow.modelData.uptime || "—"
                                        Layout.preferredWidth: 80
                                        horizontalAlignment: Text.AlignRight
                                        color: Theme.subtext1
                                    }
                                }
                            }
                        }
                        Label {
                            visible: networkWidget.serverData !== null && networkWidget.selectedDeployments.length === 0
                            text: "No deployments in " + networkWidget.namespaceFilter
                            color: Theme.subtext1
                        }
                    }
                    Button {
                        id: eventsButton
                        visible: networkWidget.recentEvents.length > 0
                        Layout.fillWidth: true
                        onClicked: networkWidget.showEvents = !networkWidget.showEvents
                        contentItem: Label {
                            text: (networkWidget.showEvents ? "▾" : "▸") + " Recent warnings (" + networkWidget.recentEvents.length + ")"
                            color: Theme.subtext1
                        }
                        background: Rectangle {
                            color: eventsButton.hovered ? Theme.surface2 : "transparent"
                            radius: Theme.radiusAlt
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: networkWidget.showEvents
                        spacing: 10
                        Repeater {
                            model: networkWidget.showEvents ? networkWidget.recentEvents : []
                            ColumnLayout {
                                id: eventRow
                                required property var modelData
                                Layout.fillWidth: true
                                spacing: 3
                                Label {
                                    Layout.fillWidth: true
                                    text: [eventRow.modelData.namespace, eventRow.modelData.name].filter(Boolean).join("/")
                                    elide: Text.ElideMiddle
                                    color: Theme.subtext1
                                    font.pixelSize: Theme.fontSizeXxs
                                }
                                Label {
                                    Layout.fillWidth: true
                                    text: eventRow.modelData.message
                                    wrapMode: Text.Wrap
                                }
                                Label {
                                    text: (eventRow.modelData.lastSeen ? Qt.formatDateTime(new Date(eventRow.modelData.lastSeen), "dd MMM HH:mm") : "") + (eventRow.modelData.count > 1 ? " · ×" + eventRow.modelData.count : "")
                                    color: Theme.subtext1
                                    font.pixelSize: Theme.fontSizeXxs
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component Label: Text {
        color: Theme.text
        font.family: Theme.fontMain
        font.pixelSize: Theme.fontSizeSm
        textFormat: Text.PlainText
    }
    component Metric: Rectangle {
        id: metric
        required property string title
        required property string value
        property string detail: ""
        property color detailColor: Theme.subtext1
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        implicitHeight: 82
        color: Theme.surface1
        radius: Theme.radiusAlt
        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 4
            Label {
                text: metric.title
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.subtext1
            }
            Label {
                text: metric.value
                font.pixelSize: Theme.fontSizeXl
                font.bold: true
            }
            Label {
                text: metric.detail
                font.pixelSize: Theme.fontSizeTiny
                color: metric.detailColor
                visible: text.length > 0
            }
        }
    }
}
