#!/usr/bin/env python3
"""Exercise real providers and popup contents without touching the desktop or cluster.
PanelWindow is replaced with an Item; polling is disabled in the temporary copies.
An optional endpoint JSON snapshot may be passed for the rendered cluster preview.
"""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

repo = Path(__file__).resolve().parents[1]
root = Path(tempfile.mkdtemp(prefix='network-kubernetes-check-'))
for name in ('Providers', 'Widgets', 'Modules', 'Components'):
    (root/name).mkdir()
for name in ('Components/NetworkTrafficGraph.qml', 'Providers/NetworkDataProvider.qml', 'Providers/KubernetesDataProvider.qml',
             'Widgets/networkWidget.qml', 'Widgets/kubernetesWidget.qml',
             'Modules/network.qml', 'Modules/kubernetes.qml'):
    contents = (repo/name).read_text().replace('property bool pollingEnabled: true', 'property bool pollingEnabled: false')
    (root/name).write_text(contents)
shutil.copy(repo/'Theme.qml', root/'Theme.qml')
shutil.copy(repo/'Core/BaseModule.qml', root/'BaseModule.qml')
(root/'BaseModule.qml').write_text((root/'BaseModule.qml').read_text().replace('import ".."', 'import "."'))
(root/'qmldir').write_text('''singleton Theme 1.0 Theme.qml
singleton SettingsManager 1.0 SettingsManager.qml
singleton WidgetManager 1.0 WidgetManager.qml
singleton NetworkDataProvider 1.0 Providers/NetworkDataProvider.qml
singleton KubernetesDataProvider 1.0 Providers/KubernetesDataProvider.qml
BaseWidget 1.0 BaseWidget.qml
BaseModule 1.0 BaseModule.qml
NetworkTrafficGraph 1.0 Components/NetworkTrafficGraph.qml
''')
(root/'SettingsManager.qml').write_text('pragma Singleton\nimport QtQuick\nQtObject { property int barHeight: 34 }')
shutil.copy(repo/'Managers/WidgetManager.qml', root/'WidgetManager.qml')
(root/'BaseWidget.qml').write_text('''import QtQuick
Item {
    required property string widgetId
    required property Component widgetComponent
    required property int widgetWidth
    required property int widgetHeight
    property var screen: ({width: 1920, height: 1080})
    width: widgetWidth; height: widgetHeight
    Loader { anchors.fill: parent; active: parent.visible; sourceComponent: parent.widgetComponent }
}
''')
fixture = {
    'status': 'ok', 'generatedAt': '2026-10-25T12:00:00Z', 'cluster': {'version': 'test'},
    'summary': {'nodes': {'total': 2, 'ready': 2}, 'deployments': {'total': 2, 'available': 2},
                'pods': {'total': 5, 'running': 4, 'succeeded': 1, 'pending': 0, 'failed': 0, 'unknown': 0}},
    'nodes': [{'name': n, 'ready': True, 'pressure': [], 'roles': [r], 'cpu': '4', 'memory': '8010136Ki', 'uptime': '1d'}
              for n, r in [('atlas', 'control-plane'), ('nyx', 'worker')]],
    'pods': [{'namespace': ns, 'name': 'pod-'+str(i), 'phase': 'Succeeded' if i == 4 else 'Running',
              'status': 'Completed' if i == 4 else 'Running', 'ready': '0/1' if i == 4 else '1/1',
              'node': 'atlas' if i % 2 else 'nyx', 'restarts': 0}
             for i, ns in enumerate(['tissla', 'tissla', 'immich', 'woodpecker', 'kube-system'])],
    'deployments': [{'namespace': ns, 'name': ns+'-app', 'desired': 1, 'ready': 1, 'available': 1, 'uptime': '1d'}
                    for ns in ('tissla', 'immich')],
    'namespaces': [{'name': n, 'services': 1} for n in ('tissla', 'immich', 'woodpecker', 'kube-system', 'empty')],
    'events': [], 'problems': []
}
preview = json.loads(Path(sys.argv[1]).read_text()) if len(sys.argv) > 1 else fixture
(root/'fixture.js').write_text('var original = '+json.dumps(fixture)+';\nvar preview = '+json.dumps(preview)+';\n')
(root/'shell.qml').write_text(r'''import QtQuick
import QtQuick.Window
import Quickshell
import "."
import "fixture.js" as Fixture
ShellRoot {
    id: test
    property var network
    property var cluster
    property var networkModule
    property var clusterModule
    property int assertions: 0
    function check(value, message) {
        assertions++;
        if (!value) throw new Error(message);
    }
    function fresh() {
        const data = JSON.parse(JSON.stringify(Fixture.original));
        data.generatedAt = new Date().toISOString();
        return data;
    }
    function load(data) { KubernetesDataProvider.acceptResponse(JSON.stringify(data), 0, 0); }
    function find(item, name) {
        if (item.objectName === name) return item;
        for (const child of item.children || []) { const match = find(child, name); if (match) return match; }
        return null;
    }
    function make(path, parent, properties) {
        const c = Qt.createComponent(path);
        check(c.status === Component.Ready, c.errorString());
        const item = c.createObject(parent, properties || {});
        check(item !== null, 'create '+path);
        return item;
    }
    Window {
        visible: true; width: 1380; height: 880; color: Theme.mantleSolid
        Item { id: contents; anchors.fill: parent }
    }
    Component.onCompleted: {
        try {
            const n = NetworkDataProvider;
            n.disconnect();
            n.acceptCounters('eth0', 0, 0, 1000);
            check(n.connected && n.history.length === 0, 'first sample is baseline');
            n.acceptCounters('eth0', 2048, 4096, 3000);
            check(n.downloadSpeed === 1 && n.uploadSpeed === 2, 'rates in KB/s with zero baseline');
            check(n.history.length === 1, 'history receives sample');
            n.acceptCounters('eth0', 1, 1, 5000);
            check(n.downloadSpeed === 0 && n.history.length === 0, 'counter reset cannot spike');
            n.acceptCounters('wlan0', 999999, 999999, 7000);
            check(n.nwInterface === 'wlan0' && n.history.length === 0, 'interface change clears baseline');
            n.acceptCounters('wlan0', NaN, 0, 8000);
            check(!n.connected && n.downloadSpeed === 0, 'invalid reading disconnects');
            for (let i=0; i<120; i++) n.acceptCounters('eth0', i*4096, i*2048, 1000+i*2000);
            check(n.history.length === 90 && n.history[0].at > n.lastTime-180000, 'bounded three minute history');
            check(n.formatSpeed(-2) === '0 KB/s' && n.formatSpeed(2048) === '2.0 MB/s', 'speed formatting');
            n.disconnect(); check(n.history.length === 0, 'disconnect clears old interface graph');

            const k = KubernetesDataProvider;
            check(!k.healthy && k.statusText === 'Loading…', 'initial state is not healthy');
            load(fresh());
            check(k.healthy && !k.stale, 'healthy fixture');
            check(k.nodes.length === 2 && k.namespaces.length === 5, 'all nodes and empty namespaces');
            check(k.runningPodCount === 4 && k.completedPodCount === 1 && k.problemPodCount === 0, 'completed jobs not faults');
            check(k.podsFor('tissla').length === 2 && k.podsFor('immich').length === 1 && k.podsFor('').length === 5, 'namespace filtering');
            check(k.deploymentsFor('woodpecker').length === 0 && k.podsFor('woodpecker').length === 1, 'non-deployment workloads');
            check(k.nodePods('nyx').total === 2, 'node counts exclude completed');
            check(k.namespaces.find(ns => ns.name === 'empty').active === 0, 'empty namespace');
            const broken = fresh();
            broken.pods[2].ready='0/1'; broken.pods[2].status='CrashLoopBackOff';
            broken.nodes[1].ready=false; broken.nodes[1].pressure=['DiskPressure'];
            broken.problems=['Server-side warning']; load(broken);
            check(!k.healthy && k.problemPodCount === 1, 'crashing running pod is a fault');
            check(k.sortedPods[0].namespace === 'immich', 'problems sorted first');
            check(k.currentProblems.some(p=>p.includes('CrashLoopBackOff')) && k.currentProblems.some(p=>p.includes('DiskPressure')), 'resource problems retained with server warnings');
            check(k.namespaces.find(ns=>ns.name==='immich').ready === 0, 'namespace ready counts reflect failure');
            load(fresh()); const retained=k.serverData;
            k.acceptResponse('',7,0); check(k.serverData === retained && !k.healthy && k.statusText === 'Unavailable','outage keeps last data without healthy badge');
            k.acceptResponse('{}',0,0); check(k.serverData === retained && k.errorMessage === 'Invalid cluster response','malformed response rejected');
            k.acceptResponse('{bad json',0,0); check(k.serverData === retained,'invalid JSON rejected');
            load(fresh()); k.now=Date.parse(k.serverData.generatedAt)+31000;
            check(k.stale && !k.healthy && k.statusText === 'Stale data','staleness visible without opening widget');
            load(fresh());
            check(WidgetManager.widgetSources.network === 'networkWidget.qml' && WidgetManager.widgetSources.kubernetes === 'kubernetesWidget.qml', 'separate registry');
            network=make('Widgets/networkWidget.qml',contents,{x:20,y:70});
            cluster=make('Widgets/kubernetesWidget.qml',contents,{x:560,y:70});
            networkModule=make('Modules/network.qml',contents,{x:20,y:15});
            clusterModule=make('Modules/kubernetes.qml',contents,{x:560,y:15});
            check(network.widgetId === 'network' && cluster.widgetId === 'kubernetes', 'popup identities');
            check(networkModule.widgetId === 'network' && clusterModule.widgetId === 'kubernetes', 'module identities');
            uiChecks.start();
        } catch (e) { console.error('CHECK_FAIL',e.stack); Qt.quit(); }
    }
    Timer {
        id: uiChecks; interval: 100
        onTriggered: {
            try {
                const row=test.find(test.cluster,'namespace-immich');
                test.check(row !== null,'namespace button rendered'); row.clicked();
                test.check(test.cluster.namespaceFilter==='immich' && test.cluster.pods.length===1 && test.cluster.detailsOpen,'namespace click opens filtered details');
                test.find(test.cluster,'allNamespaces').clicked();
                test.check(test.cluster.namespaceFilter==='' && test.cluster.pods.length===5,'reset to all namespaces');
                test.find(test.cluster,'deploymentsTab').clicked();
                test.check(test.cluster.detailTab==='deployments' && test.cluster.deployments.length===2,'deployment tab');
                const sample = JSON.parse(JSON.stringify(Fixture.preview)); sample.generatedAt=new Date().toISOString();
                test.load(sample); test.cluster.detailsOpen=false;
                const n=NetworkDataProvider; n.disconnect();
                let rx=0,tx=0;
                for(let i=0;i<=90;i++) {
                    rx+=(30+Math.pow(Math.sin(i*.17),6)*3600)*2048;
                    tx+=(20+Math.pow(Math.sin(i*.14+.4),4)*500)*2048;
                    n.acceptCounters('enp5s0',rx,tx,Date.now()-180000+i*2000);
                }
                capture.start();
            } catch(e) { console.error('CHECK_FAIL',e.stack); Qt.quit(); }
        }
    }
    Timer {
        id: capture; interval: 200
        onTriggered: contents.grabToImage(result => {
            result.saveToFile(Quickshell.shellDir+'/overview.png');
            console.log('CHECK_PASS',test.assertions); Qt.quit();
        })
    }
}
''')
(root/'runtime').mkdir(mode=0o700)
env = dict(os.environ, QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software', QT_QPA_PLATFORMTHEME='',
           XDG_RUNTIME_DIR=str(root/'runtime'), XDG_CACHE_HOME=str(root/'cache'))
env.pop('WAYLAND_DISPLAY', None)
result = subprocess.run(['quickshell', '--path', str(root), '--no-color'], env=env, text=True, capture_output=True, timeout=15)
output = result.stdout + result.stderr
print(root)
print(output)
if result.returncode or 'CHECK_PASS' not in output or any(s in output for s in ('CHECK_FAIL','TypeError','ReferenceError','Binding loop','Failed to load','Cannot assign','Unable to assign')):
    raise SystemExit(1)
