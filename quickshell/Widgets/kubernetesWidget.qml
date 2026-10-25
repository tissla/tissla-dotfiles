pragma ComponentBehavior: Bound
import ".."
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

BaseWidget {
    id: kubernetesWidget
    widgetId: "kubernetes"
    widgetWidth: Math.min(780, screen ? screen.width - 40 : 780)
    widgetHeight: Math.min(800, screen ? screen.height - 100 : 800)
    property string namespaceFilter: ""
    property string detailTab: "pods"
    property bool detailsOpen: false
    readonly property var provider: KubernetesDataProvider
    readonly property var pods: provider.podsFor(namespaceFilter)
    readonly property var deployments: provider.deploymentsFor(namespaceFilter)
    readonly property var events: provider.eventsFor(namespaceFilter)
    readonly property bool uncertain: !!provider.errorMessage || provider.stale
    onVisibleChanged: if (visible) provider.fetch()
    Connections {
        target: KubernetesDataProvider
        function onProblemPodCountChanged() {
            if (KubernetesDataProvider.problemPodCount > 0) {
                kubernetesWidget.detailsOpen = true;
                kubernetesWidget.detailTab = "pods";
            }
        }
        function onNamespacesChanged() {
            if (kubernetesWidget.namespaceFilter && !KubernetesDataProvider.namespaces.some(n => n.name === kubernetesWidget.namespaceFilter))
                kubernetesWidget.namespaceFilter = "";
        }
    }
    signal revealDetails()
    function selectNamespace(name) {
        namespaceFilter = name;
        detailsOpen = true;
        revealDetails();
    }
    function selectTab(tab) {
        detailsOpen = detailTab !== tab || !detailsOpen;
        detailTab = tab;
        if (detailsOpen) revealDetails();
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
                Label { text: "Kubernetes"; font.pixelSize: Theme.fontSizeXl; font.bold: true; Layout.fillWidth: true }
                Rectangle { implicitWidth: 7; implicitHeight: 7; radius: 4; color: KubernetesDataProvider.statusColor }
                Label { text: KubernetesDataProvider.statusText; color: KubernetesDataProvider.statusColor }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: KubernetesDataProvider.serverData ? KubernetesDataProvider.serverData.cluster.version
                        + " · " + KubernetesDataProvider.namespaces.length + " namespaces" : ""
                    font.pixelSize: Theme.fontSizeXxs; color: Theme.subtext1; Layout.fillWidth: true
                }
                Label {
                    text: KubernetesDataProvider.serverData ? "Updated " + Qt.formatDateTime(new Date(KubernetesDataProvider.serverData.generatedAt), "HH:mm:ss") : ""
                    font.pixelSize: Theme.fontSizeXxs; color: Theme.subtext1
                }
            }
            Label {
                visible: kubernetesWidget.uncertain
                Layout.fillWidth: true
                text: KubernetesDataProvider.errorMessage ? KubernetesDataProvider.errorMessage
                    + (KubernetesDataProvider.serverData ? " · showing last response" : "") : "The endpoint is returning an old snapshot"
                color: Theme.warning; wrapMode: Text.Wrap
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
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Metric {
                            title: "NODES READY"
                            value: KubernetesDataProvider.serverData ? KubernetesDataProvider.serverData.summary.nodes.ready + "/" + KubernetesDataProvider.serverData.summary.nodes.total : "—"
                        }
                        Metric {
                            title: "PODS READY"
                            value: KubernetesDataProvider.serverData ? KubernetesDataProvider.runningPodCount + "/" + (KubernetesDataProvider.sortedPods.length - KubernetesDataProvider.completedPodCount) : "—"
                            detail: KubernetesDataProvider.completedPodCount + " completed"
                        }
                        Metric {
                            title: "DEPLOYMENTS"
                            value: KubernetesDataProvider.serverData ? KubernetesDataProvider.serverData.summary.deployments.available + "/" + KubernetesDataProvider.serverData.summary.deployments.total : "—"
                        }
                    }
                    ColumnLayout {
                        visible: KubernetesDataProvider.currentProblems.length > 0
                        Layout.fillWidth: true
                        spacing: 4
                        Section { text: "PROBLEMS · ALL NAMESPACES"; color: Theme.warning }
                        Repeater {
                            model: KubernetesDataProvider.currentProblems
                            Label { required property string modelData; text: modelData; Layout.fillWidth: true; wrapMode: Text.Wrap; color: Theme.warning }
                        }
                    }
                    Section { text: "NODES" }
                    GridLayout {
                        Layout.fillWidth: true
                        columns: scroll.availableWidth < 550 ? 1 : 2
                        columnSpacing: 8; rowSpacing: 8
                        Repeater {
                            model: KubernetesDataProvider.nodes
                            Rectangle {
                                id: nodeCard
                                required property var modelData
                                readonly property var pods: KubernetesDataProvider.nodePods(modelData.name)
                                readonly property bool healthy: modelData.ready && !modelData.pressure.length
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                implicitHeight: nodeContent.implicitHeight + 24
                                color: Theme.surface0
                                radius: Theme.radiusAlt
                                ColumnLayout {
                                    id: nodeContent
                                    anchors.fill: parent; anchors.margins: 12; spacing: 5
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Label { text: nodeCard.modelData.name; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
                                        Label {
                                            text: !nodeCard.modelData.ready ? "Not ready" : nodeCard.modelData.pressure.length ? "Pressure" : "Ready"
                                            color: kubernetesWidget.uncertain ? Theme.muted : nodeCard.healthy ? Theme.success : Theme.warning
                                        }
                                    }
                                    Label {
                                        text: (nodeCard.modelData.roles || []).join(", ") + " · " + (nodeCard.modelData.uptime || "—")
                                        font.pixelSize: Theme.fontSizeXxs; color: Theme.subtext1
                                    }
                                    Label {
                                        text: nodeCard.pods.ready + "/" + nodeCard.pods.total + " active pods ready"
                                        font.pixelSize: Theme.fontSizeXxs
                                    }
                                    Label {
                                        text: "Capacity: " + (nodeCard.modelData.cpu || "—") + " CPU · " + KubernetesDataProvider.memoryCapacity(nodeCard.modelData.memory)
                                        font.pixelSize: Theme.fontSizeXxs; color: Theme.subtext1
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Section { text: "NAMESPACES"; Layout.fillWidth: true }
                        Choice {
                            objectName: "allNamespaces"
                            text: "All namespaces"
                            selected: kubernetesWidget.namespaceFilter === ""
                            onClicked: kubernetesWidget.namespaceFilter = ""
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 10; Layout.rightMargin: 10
                        spacing: 8
                        Section { text: "NAME"; Layout.fillWidth: true }
                        Section { text: "PODS READY"; Layout.preferredWidth: 85; horizontalAlignment: Text.AlignRight }
                        Section { text: "DONE"; Layout.preferredWidth: 45; horizontalAlignment: Text.AlignRight }
                        Section { text: "DEPLOYMENTS"; Layout.preferredWidth: 100; horizontalAlignment: Text.AlignRight }
                        Section { text: "SERVICES"; Layout.preferredWidth: 65; horizontalAlignment: Text.AlignRight }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Repeater {
                            model: KubernetesDataProvider.namespaces
                            Button {
                                id: namespaceRow
                                required property var modelData
                                objectName: "namespace-" + modelData.name
                                Layout.fillWidth: true
                                implicitHeight: 32
                                leftPadding: 10; rightPadding: 10
                                onClicked: kubernetesWidget.selectNamespace(modelData.name)
                                background: Rectangle {
                                    color: kubernetesWidget.namespaceFilter === namespaceRow.modelData.name ? Qt.alpha(Theme.accent, 0.2)
                                        : namespaceRow.hovered ? Theme.surface1 : Theme.surface0
                                    radius: Theme.radiusAlt
                                }
                                contentItem: RowLayout {
                                    spacing: 8
                                    Label {
                                        text: namespaceRow.modelData.name + (namespaceRow.modelData.issues ? "  !" : "")
                                        color: namespaceRow.modelData.issues ? Theme.warning : Theme.text
                                        Layout.fillWidth: true; elide: Text.ElideRight
                                    }
                                    Label {
                                        text: namespaceRow.modelData.ready + "/" + namespaceRow.modelData.active
                                        color: kubernetesWidget.uncertain ? Theme.muted : namespaceRow.modelData.ready < namespaceRow.modelData.active ? Theme.warning : Theme.text
                                        Layout.preferredWidth: 85; horizontalAlignment: Text.AlignRight
                                    }
                                    Label { text: namespaceRow.modelData.completed; Layout.preferredWidth: 45; horizontalAlignment: Text.AlignRight; color: Theme.subtext1 }
                                    Label { text: namespaceRow.modelData.available + "/" + namespaceRow.modelData.deployments; Layout.preferredWidth: 100; horizontalAlignment: Text.AlignRight }
                                    Label { text: namespaceRow.modelData.services === null ? "—" : namespaceRow.modelData.services; Layout.preferredWidth: 65; horizontalAlignment: Text.AlignRight; color: Theme.subtext1 }
                                }
                            }
                        }
                    }
                    Section { id: detailsHeading; visible: kubernetesWidget.detailsOpen; text: kubernetesWidget.namespaceFilter ? "NAMESPACE · " + kubernetesWidget.namespaceFilter : "ALL NAMESPACES" }
                    ColumnLayout {
                        visible: kubernetesWidget.detailsOpen && kubernetesWidget.detailTab === "pods"
                        Layout.fillWidth: true; spacing: 4
                        Repeater {
                            model: kubernetesWidget.detailsOpen && kubernetesWidget.detailTab === "pods" ? kubernetesWidget.pods : []
                            Rectangle {
                                id: podRow
                                required property var modelData
                                readonly property bool issue: KubernetesDataProvider.podHasProblem(modelData)
                                Layout.fillWidth: true
                                implicitHeight: podContent.implicitHeight + 16
                                color: Theme.surface0; radius: Theme.radiusAlt
                                ColumnLayout {
                                    id: podContent
                                    anchors.fill: parent; anchors.margins: 8; spacing: 4
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Label { text: podRow.modelData.name; Layout.fillWidth: true; wrapMode: Text.WrapAnywhere; color: podRow.issue ? Theme.warning : Theme.text }
                                        Label { text: KubernetesDataProvider.podStatus(podRow.modelData); color: kubernetesWidget.uncertain ? Theme.muted : podRow.issue ? Theme.warning : podRow.modelData.phase === "Succeeded" ? Theme.subtext1 : Theme.success }
                                    }
                                    Label {
                                        text: podRow.modelData.namespace + " · " + (podRow.modelData.node || "Unscheduled")
                                            + " · " + podRow.modelData.ready + " ready · " + (podRow.modelData.restarts || 0) + " restarts"
                                        Layout.fillWidth: true; wrapMode: Text.Wrap
                                        font.pixelSize: Theme.fontSizeXxs; color: Theme.subtext1
                                    }
                                }
                            }
                        }
                        Label { visible: kubernetesWidget.pods.length === 0; text: "No pods"; color: Theme.muted }
                    }
                    ColumnLayout {
                        visible: kubernetesWidget.detailsOpen && kubernetesWidget.detailTab === "deployments"
                        Layout.fillWidth: true; spacing: 4
                        Repeater {
                            model: kubernetesWidget.detailsOpen && kubernetesWidget.detailTab === "deployments" ? kubernetesWidget.deployments : []
                            Rectangle {
                                id: deploymentRow
                                required property var modelData
                                Layout.fillWidth: true; implicitHeight: 54
                                color: Theme.surface0; radius: Theme.radiusAlt
                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 8; spacing: 8
                                    ColumnLayout {
                                        Layout.fillWidth: true; spacing: 3
                                        Label { text: deploymentRow.modelData.name; Layout.fillWidth: true; elide: Text.ElideRight }
                                        Label { text: deploymentRow.modelData.namespace + " · " + (deploymentRow.modelData.uptime || "—"); color: Theme.subtext1; font.pixelSize: Theme.fontSizeXxs }
                                    }
                                    Label {
                                        text: deploymentRow.modelData.ready + "/" + deploymentRow.modelData.desired + " ready · " + deploymentRow.modelData.available + " available"
                                        color: kubernetesWidget.uncertain ? Theme.muted : KubernetesDataProvider.deploymentReady(deploymentRow.modelData) ? Theme.success : Theme.warning
                                    }
                                }
                            }
                        }
                        Label { visible: kubernetesWidget.deployments.length === 0; text: "No deployments"; color: Theme.muted }
                    }
                    ColumnLayout {
                        visible: kubernetesWidget.detailsOpen && kubernetesWidget.detailTab === "events"
                        Layout.fillWidth: true; spacing: 10
                        Repeater {
                            model: kubernetesWidget.detailsOpen && kubernetesWidget.detailTab === "events" ? kubernetesWidget.events : []
                            ColumnLayout {
                                id: eventRow
                                required property var modelData
                                Layout.fillWidth: true; spacing: 3
                                Label { text: [eventRow.modelData.namespace, eventRow.modelData.name].filter(Boolean).join("/"); Layout.fillWidth: true; wrapMode: Text.WrapAnywhere; color: Theme.subtext1; font.pixelSize: Theme.fontSizeXxs }
                                Label { text: eventRow.modelData.message; Layout.fillWidth: true; wrapMode: Text.Wrap }
                                Label { text: (eventRow.modelData.lastSeen ? Qt.formatDateTime(new Date(eventRow.modelData.lastSeen), "dd MMM HH:mm") : "") + (eventRow.modelData.count > 1 ? " · ×" + eventRow.modelData.count : ""); color: Theme.subtext1; font.pixelSize: Theme.fontSizeXxs }
                            }
                        }
                        Label { visible: kubernetesWidget.events.length === 0; text: "No recent warnings"; color: Theme.muted }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Choice { objectName: "podsTab"; text: "Pods · " + kubernetesWidget.pods.length; selected: kubernetesWidget.detailsOpen && kubernetesWidget.detailTab === "pods"; onClicked: kubernetesWidget.selectTab("pods") }
                Choice { objectName: "deploymentsTab"; text: "Deployments · " + kubernetesWidget.deployments.length; selected: kubernetesWidget.detailsOpen && kubernetesWidget.detailTab === "deployments"; onClicked: kubernetesWidget.selectTab("deployments") }
                Choice { objectName: "eventsTab"; text: "Warnings · " + kubernetesWidget.events.length; selected: kubernetesWidget.detailsOpen && kubernetesWidget.detailTab === "events"; onClicked: kubernetesWidget.selectTab("events") }
                Item { Layout.fillWidth: true }
            }
        }
        Connections {
            target: kubernetesWidget
            function onRevealDetails() { revealTimer.restart(); }
        }
        Timer {
            id: revealTimer
            interval: 20
            onTriggered: {
                if (kubernetesWidget.detailsOpen)
                    scroll.contentItem.contentY = Math.min(detailsHeading.y,
                        Math.max(0, scroll.contentHeight - scroll.availableHeight));
            }
        }
    }
    component Label: Text {
        color: Theme.text
        font.family: Theme.fontMain
        font.pixelSize: Theme.fontSizeSm
        textFormat: Text.PlainText
    }
    component Section: Label { font.pixelSize: Theme.fontSizeTiny; color: Theme.subtext1 }
    component Choice: Button {
        id: choice
        property bool selected: false
        implicitHeight: 30
        leftPadding: 10; rightPadding: 10
        contentItem: Label { text: choice.text; color: choice.selected ? Theme.accent : Theme.subtext1; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
        background: Rectangle { color: choice.selected ? Qt.alpha(Theme.accent, 0.15) : choice.hovered ? Theme.surface1 : Theme.surface0; radius: Theme.radiusAlt }
    }
    component Metric: Rectangle {
        id: metric
        required property string title
        required property string value
        property string detail: ""
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        implicitHeight: 78
        color: Theme.surface1
        radius: Theme.radiusAlt
        Column {
            anchors.fill: parent; anchors.margins: 10; spacing: 3
            Section { text: metric.title }
            Label { text: metric.value; font.pixelSize: Theme.fontSizeXl; font.bold: true }
            Section { text: metric.detail; visible: text.length > 0 }
        }
    }
}
