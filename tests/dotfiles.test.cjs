// Run with: node tests/dotfiles.test.cjs
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const root = path.resolve(__dirname, '..');
const read = file => fs.readFileSync(path.join(root, file), 'utf8');

// Execute the provider's actual JavaScript without starting desktop services.
function weather(points) {
  const source = read('quickshell/Providers/WeatherDataProvider.qml');
  let result;
  const context = vm.createContext({
    weatherData: { weatherDataReady: value => { result = value; } },
  });
  const icons = source.slice(source.indexOf('property var weatherIcons:') + 'property var weatherIcons:'.length,
    source.indexOf('signal weatherDataReady'));
  const parser = source.slice(source.indexOf('function parseWeatherData('), source.indexOf('    getWeatherDataProcess: Process'));
  vm.runInContext('var weatherIcons = ' + icons + ';\n' + parser, context);
  context.parseWeatherData({ properties: { timeseries: points } });
  return JSON.parse(JSON.stringify(result));
}

function point(symbol = 'clearsky_day', temperature = 5, age = 0) {
  return { time: new Date(Date.now() - age).toISOString(), data: {
    instant: { details: { air_temperature: temperature } },
    next_1_hours: { summary: { symbol_code: symbol } },
  } };
}

test('weather preserves zero degrees', () => {
  assert.equal(weather([point('clearsky_day', 0)])[0].temp, 0);
});
test('weather resolves day/night variants of shower icons', () => {
  assert.equal(weather([point('rainshowers_day')])[0].wText, 'Rain showers');
});
test('weather uses a fallback for unknown symbols', () => {
  assert.equal(weather([point('unknown')])[0].wText, 'No data');
});
test('weather returns no current points for a stale or empty response', () => {
  assert.deepEqual(weather([point('clearsky_day', 5, 7200000)]), []);
  assert.deepEqual(weather([]), []);
});
test('weather tolerates missing hourly summaries', () => {
  const p = point();
  delete p.data.next_1_hours;
  assert.equal(weather([p])[0].temp, 5);
});
test('default settings can be parsed and provide a primary wallpaper', () => {
  const settings = JSON.parse(read('quickshell/defaultsettings.json'));
  const screen = settings.screens.find(s => s.isPrimary);
  assert.equal(typeof screen.wallpaper, 'string');
  assert.ok(fs.existsSync(path.join(root, 'wallpapers', screen.wallpaper)));
});
test('terminal controls remain busy while saving, generating, or reloading', () => {
  const source = read('quickshell/Managers/SettingsManager.qml');
  const expression = source.match(/readonly property bool terminalSettingsBusy: (.+)/)[1];
  for (const [saving, generating, reloading, expected] of [
    [false, false, false, false], [true, false, false, true],
    [false, true, false, true], [false, false, true, true],
  ]) {
    const context = { _rebuildTerminal: saving, settingsSaver: null,
      ThemeManager: { generateProcess: {running: generating}, hyprctlProcess: {running: reloading} } };
    assert.equal(vm.runInNewContext(expression, context), expected);
  }
});
