#!/usr/bin/env python3
"""Read physical peripherals from udev/sysfs; never open input event devices."""
import json
from pathlib import Path
import re
import subprocess
import sys

KINDS = ('controller', 'tablet', 'touchpad', 'keyboard', 'mouse', 'camera', 'audio')
INPUT_KINDS = {'JOYSTICK': 'controller', 'TABLET': 'tablet', 'TOUCHPAD': 'touchpad',
               'KEYBOARD': 'keyboard', 'MOUSE': 'mouse', 'TOUCHSCREEN': 'tablet'}
HID = re.compile(r'^[0-9a-f]{4}:[0-9a-f]{4}:[0-9a-f]{4}\.[0-9a-f]+$', re.I)
ADDRESS = re.compile(r'^[0-9a-f]{2}(?::[0-9a-f]{2}){5}$', re.I)


def read(path):
    try:
        return path.read_text().strip()
    except (OSError, UnicodeError):
        return ''  # A device may be removed between enumeration and reading.


def parse_udev(text):
    records = []
    for block in text.split('\n\n'):
        props = {}
        for line in block.splitlines():
            if line.startswith('P: '):
                props['DEVPATH'] = line[3:]
            elif line.startswith('E: ') and '=' in line:
                key, value = line[3:].split('=', 1)
                props[key] = value
        if props.get('DEVPATH'):
            records.append(props)
    return records


def ancestors(path, root):
    while path != root and root in path.parents:
        yield path
        path = path.parent


def snapshot(sys_root, records):
    root = Path(sys_root).resolve()
    entries = []
    controller_roots = {}
    for props in records:
        devpath = props.get('DEVPATH', '')
        if not devpath.startswith('/devices/') or devpath.startswith('/devices/virtual/input/'):
            continue
        path = (root / devpath.lstrip('/')).resolve()
        if not path.exists() or root not in path.parents:
            continue
        subsystem = props.get('SUBSYSTEM')
        kind = None
        name = ''
        uniq = ''
        if subsystem == 'input' and re.fullmatch(r'event\d+', path.name):
            kind = next((value for flag, value in INPUT_KINDS.items() if props.get('ID_INPUT_' + flag) == '1'), None)
            name = read(path.parent / 'name')
            uniq = read(path.parent / 'uniq')
        elif subsystem == 'sound' and re.fullmatch(r'card\d+', path.name):
            kind = 'audio'
        elif subsystem == 'video4linux' and re.fullmatch(r'video\d+', path.name):
            kind = 'camera'
        if not kind:
            continue

        parents = list(ancestors(path, root))
        usb = next((p for p in parents if (p / 'idVendor').exists() and (p / 'idProduct').exists()), None)
        hids = [p for p in parents if HID.fullmatch(p.name)]
        bluetooth = props.get('ID_BUS') == 'bluetooth' or any(p.name.startswith('0005:') for p in hids)
        address = uniq.lower() if bluetooth and ADDRESS.fullmatch(uniq) else ''
        if bluetooth:
            physical = hids[0] if hids else path.parent.parent
            identity = 'bluetooth:' + (address or str(physical.relative_to(root)))
            transport = 'Bluetooth'
        elif usb:
            # Nested HID devices are separate peripherals behind a shared receiver.
            physical = hids[0] if len(hids) > 1 else usb
            identity = 'usb:' + str(physical.relative_to(root))
            transport = 'USB'
            if physical == usb and kind != 'controller':
                name = read(usb / 'product') or name
        else:
            continue  # Internal sound cards, hotkeys and power buttons are not accessories.

        if kind == 'controller' and not bluetooth:
            controller_roots.setdefault(identity, set()).add(hids[0] if hids else path.parent)
        entries.append({'id': identity, 'name': name or props.get('ID_MODEL', '').replace('_', ' ') or 'Peripheral',
                        'kind': kind, 'transport': transport, 'address': address,
                        'battery': None, 'charging': False, '_physical': physical, '_path': path})

    groups = {}
    for entry in entries:
        # Non-HID receivers (e.g. xpad) expose one input root per connected pad.
        # Only split when several controller roots exist; a single pad's audio,
        # touchpad and buttons still belong to one physical peripheral.
        roots = controller_roots.get(entry['id'], set())
        if len(roots) > 1:
            controller = next((p for p in roots if p in entry['_path'].parents), None)
            if controller:
                entry['id'] = 'usb:' + str(controller.relative_to(root))
                entry['_physical'] = controller
        del entry['_path']
        previous = groups.get(entry['id'])
        if not previous or KINDS.index(entry['kind']) < KINDS.index(previous['kind']):
            groups[entry['id']] = entry

    # Match by sysfs ancestry, never by the (often identical) model name.
    for battery in (root / 'class/power_supply').glob('*'):
        battery_path = battery.resolve()
        if read(battery / 'present') == '0':
            continue
        value = read(battery / 'capacity')
        if not value.isdecimal() or not 0 <= int(value) <= 100:
            continue
        candidates = [d for d in groups.values() if d['_physical'] in battery_path.parents]
        if len(candidates) == 1:
            candidates[0]['battery'] = int(value)
            candidates[0]['charging'] = read(battery / 'status').lower() == 'charging'
    for device in groups.values():
        del device['_physical']
    return sorted(groups.values(), key=lambda d: (KINDS.index(d['kind']), d['name'].casefold(), d['id']))


def main():
    try:
        result = subprocess.run(['udevadm', 'info', '--export-db'], capture_output=True, text=True, check=True, timeout=5)
        print(json.dumps(snapshot(Path('/sys'), parse_udev(result.stdout))))
    except (OSError, subprocess.SubprocessError) as error:
        print('Peripheral discovery failed: ' + str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
