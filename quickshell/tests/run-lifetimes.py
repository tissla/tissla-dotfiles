#!/usr/bin/env python3
"""Run real QML ownership logic with inert process IO, without touching the desktop."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='quickshell-lifetimes-') as directory:
    stage = Path(directory)
    names = ['PerformanceDataProvider', 'DevicesDataProvider', 'WidgetManager']
    for name in names:
        folder = 'Managers' if name == 'WidgetManager' else 'Providers'
        source = (repo / folder / (name + '.qml')).read_text()
        (stage / (name + '.qml')).write_text(source.replace('import Quickshell.Io', 'import "."'))
    (stage / 'qmldir').write_text('\n'.join(f'singleton {n} 1.0 {n}.qml' for n in names))
    (stage / 'BaseWidget.qml').write_text((repo / 'Core/BaseWidget.qml').read_text().replace('import ".."', 'import "."').replace('import Quickshell', ''))
    (stage / 'PanelWindow.qml').write_text('''import QtQuick
QtObject {
 default property list<QtObject> data
 property var screen: null
 property bool visible: false
 property bool focusable: false
 property color color
 property real implicitWidth: 0
 property real implicitHeight: 0
 property WindowEdges anchors: WindowEdges {}
 property WindowEdges margins: WindowEdges {}
}''')
    (stage / 'WindowEdges.qml').write_text('import QtQuick\nQtObject { property var bottom; property var left }')
    fixtures = {
        'SettingsManager': 'property string barPosition: "bottom"; property int barHeight: 34; function isPrimary(name) { return true; }',
        'PlaySoundService': 'function playSound(name) {}',
        'Quickshell': 'property var screens: []',
        'WeatherDataProvider': 'signal weatherDataReady(var data); function getWeatherData() {}',
        'WallpaperManager': 'property var wallpapers: ({}); property var availableWallpapers: []; property string wallpapersPath: "' + str(stage) + '"',
        'ThemeManager': 'property var availableThemes: []; property string activeTheme: "test"',
    }
    with (stage / 'qmldir').open('a') as manifest:
        for name, body in fixtures.items():
            (stage / (name + '.qml')).write_text('pragma Singleton\nimport QtQuick\nQtObject { ' + body + ' }')
            manifest.write(f'\nsingleton {name} 1.0 {name}.qml')
    (stage / 'Process.qml').write_text('''import QtQuick
QtObject {
 property bool running: false
 property var command: []
 property QtObject stdout
 property QtObject stderr
 signal exited(int exitCode, int exitStatus)
}''')
    (stage / 'SplitParser.qml').write_text('import QtQuick\nQtObject { signal read(string data) }')
    (stage / 'StdioCollector.qml').write_text('import QtQuick\nQtObject { property string text: ""; signal streamFinished() }')
    for source, target in [('Core/BaseModule.qml', 'BaseModule.qml'), ('Modules/cpu.qml', 'CpuModule.qml'), ('Modules/devices.qml', 'DevicesModule.qml'), ('Components/ProgressCircle.qml', 'ProgressCircle.qml')]:
        (stage / target).write_text((repo / source).read_text().replace('import ".."', 'import "."'))
    shutil.copy(repo / 'Theme.qml', stage)
    with (stage / 'qmldir').open('a') as manifest:
        manifest.write('\nsingleton Theme 1.0 Theme.qml')
    for source, target in [('Lock/LockSurface.qml', 'LockSurface.qml'), ('Widgets/themeWidget.qml', 'ThemeWidget.qml')]:
        (stage / target).write_text((repo / source).read_text().replace('import ".."', 'import "."').replace('import Quickshell', ''))
    (stage / 'large.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="4000" height="2000"><rect width="4000" height="2000" fill="green"/></svg>')
    shutil.copy(repo / 'tests/tst_lifetimes.qml', stage)
    env = dict(os.environ, QT_QPA_PLATFORM='offscreen', QT_QPA_PLATFORMTHEME='',
               QT_QUICK_CONTROLS_STYLE='Basic', QT_FORCE_STDERR_LOGGING='1')
    result = subprocess.run(['/usr/lib/qt6/bin/qmltestrunner', '-input', str(stage)], env=env)
    raise SystemExit(result.returncode)
