pragma Singleton
import ".."
import QtQuick
import Quickshell.Io

QtObject {
    id: cluster
    property string endpoint: "http://192.168.1.240:30099/info"
    property bool pollingEnabled: true
    property var serverData: null
    property string errorMessage: ""
    property double now: Date.now()
    readonly property bool fetching: fetchProcess.running
    readonly property bool stale: serverData !== null && now - Date.parse(serverData.generatedAt) > 30000
    readonly property var currentProblems: serverData ? problemsFor(serverData) : []
    readonly property bool healthy: serverData !== null && !errorMessage && !stale && serverData.status === "ok" && currentProblems.length === 0
    readonly property string statusText: errorMessage ? "Unavailable" : !serverData ? "Loading…" : stale ? "Stale data" : healthy ? "Healthy" : "Needs attention"
    readonly property color statusColor: errorMessage ? Theme.red : !serverData || stale ? Theme.muted : healthy ? Theme.success : Theme.warning
    readonly property var sortedPods: serverData ? serverData.pods.slice().sort((a, b) => Number(podHasProblem(b)) - Number(podHasProblem(a)) || a.namespace.localeCompare(b.namespace) || a.name.localeCompare(b.name)) : []
    readonly property int problemPodCount: sortedPods.filter(p => podHasProblem(p)).length
    readonly property int runningPodCount: sortedPods.filter(p => p.phase === "Running" && !podHasProblem(p)).length
    readonly property int completedPodCount: sortedPods.filter(p => p.phase === "Succeeded").length
    readonly property var namespaces: namespaceSummaries()
    readonly property var nodes: serverData ? serverData.nodes.slice().sort((a, b) => Number(a.ready) - Number(b.ready) || a.name.localeCompare(b.name)) : []
    readonly property var recentEvents: serverData ? serverData.events.slice().sort((a, b) => (Date.parse(b.lastSeen) || 0) - (Date.parse(a.lastSeen) || 0)) : []

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
        const problems = data.problems.map(problemText);
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
        return Array.from(new Set(problems));
    }

    function validResponse(data) {
        const count = value => Number.isInteger(value) && value >= 0;
        const group = (value, keys) => value && keys.every(key => count(value[key]));
        return data && (data.namespaces === undefined || (Array.isArray(data.namespaces) && data.namespaces.every(n => n && typeof n.name === "string"))) && typeof data.status === "string" && Number.isFinite(Date.parse(data.generatedAt)) && data.cluster && typeof data.cluster.version === "string" && data.summary && group(data.summary.nodes, ["total", "ready"]) && group(data.summary.deployments, ["total", "available"]) && group(data.summary.pods, ["total", "running", "pending", "succeeded", "failed", "unknown"]) && Array.isArray(data.nodes) && data.nodes.every(n => n && typeof n.name === "string" && typeof n.ready === "boolean" && Array.isArray(n.pressure)) && Array.isArray(data.deployments) && data.deployments.every(d => d && typeof d.namespace === "string" && typeof d.name === "string" && group(d, ["desired", "ready", "available"])) && Array.isArray(data.pods) && data.pods.every(p => p && typeof p.namespace === "string" && typeof p.name === "string" && typeof p.phase === "string" && typeof p.status === "string" && /^\d+\/\d+$/.test(p.ready)) && Array.isArray(data.problems) && data.problems.every(p => p && (typeof p === "string" || typeof p === "object")) && Array.isArray(data.events) && data.events.every(e => e && typeof e.message === "string");
    }


    function namespaceSummaries() {
        if (!serverData) return [];
        const supplied = serverData.namespaces || [];
        const names = new Set(supplied.map(n => n.name));
        for (const p of serverData.pods) names.add(p.namespace);
        for (const d of serverData.deployments) names.add(d.namespace);
        return Array.from(names).sort().map(name => {
            const pods = serverData.pods.filter(p => p.namespace === name);
            const deployments = serverData.deployments.filter(d => d.namespace === name);
            const metadata = supplied.find(n => n.name === name);
            const completed = pods.filter(p => p.phase === "Succeeded").length;
            return {name: name, total: pods.length, active: pods.length - completed,
                ready: pods.filter(p => p.phase === "Running" && !podHasProblem(p)).length,
                completed: completed, issues: pods.filter(p => podHasProblem(p)).length
                    + deployments.filter(d => !deploymentReady(d)).length,
                deployments: deployments.length, available: deployments.filter(deploymentReady).length,
                services: metadata && Number.isInteger(metadata.services) ? metadata.services : null};
        });
    }
    function podsFor(namespaceName) {
        return sortedPods.filter(p => !namespaceName || p.namespace === namespaceName);
    }
    function deploymentsFor(namespaceName) {
        return serverData ? serverData.deployments.filter(d => !namespaceName || d.namespace === namespaceName)
            .sort((a, b) => Number(deploymentReady(a)) - Number(deploymentReady(b))
                || a.namespace.localeCompare(b.namespace) || a.name.localeCompare(b.name)) : [];
    }
    function eventsFor(namespaceName) {
        return recentEvents.filter(e => !namespaceName || e.namespace === namespaceName);
    }
    function nodePods(name) {
        const pods = sortedPods.filter(p => p.node === name && p.phase !== "Succeeded");
        return {ready: pods.filter(p => !podHasProblem(p)).length, total: pods.length};
    }
    function memoryCapacity(value) {
        const match = String(value || "").match(/^(\d+(?:\.\d+)?)(Ki|Mi|Gi|Ti|K|M|G|T)?$/);
        if (!match) return "—";
        const units = {Ki: 1024, Mi: 1048576, Gi: 1073741824, Ti: 1099511627776, K: 1000, M: 1000000, G: 1000000000, T: 1000000000000};
        return (Number(match[1]) * (units[match[2]] || 1) / 1073741824).toFixed(1) + " GiB";
    }
    function fetch() {
        if (!fetchProcess.running) fetchProcess.running = true;
    }
    function acceptResponse(text, exitCode, exitStatus) {
        now = Date.now();
        if (exitCode !== 0 || exitStatus !== 0) {
            errorMessage = "Cannot reach cluster endpoint";
            return;
        }
        try {
            const data = JSON.parse(text);
            if (!validResponse(data)) throw new Error("Incomplete cluster response");
            serverData = data;
            errorMessage = "";
        } catch (error) { errorMessage = "Invalid cluster response"; }
    }
    property Timer pollTimer: Timer {
        interval: 5000
        running: cluster.pollingEnabled
        repeat: true
        triggeredOnStart: true
        onTriggered: cluster.fetch()
    }
    property Timer ageTimer: Timer {
        interval: 1000
        running: cluster.pollingEnabled
        repeat: true
        onTriggered: cluster.now = Date.now()
    }
    property Process fetchProcess: Process {
        command: ["curl", "--fail", "--silent", "--show-error", "--connect-timeout", "2", "--max-time", "4", cluster.endpoint]
        stdout: StdioCollector { id: response }
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => cluster.acceptResponse(response.text, exitCode, exitStatus)
    }
}
