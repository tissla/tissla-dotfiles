"""Run: python tests/install_test.py (never runs the installer itself)."""
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
INSTALLER = (ROOT / 'install.sh').read_text()


class InstallTests(unittest.TestCase):
    def test_generated_settings_have_wallpaper_on_screen(self):
        block = INSTALLER[INSTALLER.index('SETTINGS_JSON='):]
        settings = json.loads(block.split("<<'EOF'\n", 1)[1].split('\nEOF', 1)[0])
        screen = settings['screens'][0]
        self.assertTrue((ROOT / 'wallpapers' / screen['wallpaper']).is_file())
        self.assertNotIn('wallpaper', screen['modules'])

    def test_bashrc_loads_colors(self):
        block = INSTALLER[INSTALLER.index('BASHRC='):]
        bashrc = block.split("<<'EOF'\n", 1)[1].split('\nEOF', 1)[0]
        # Run the color-loading portion, without the interactive-shell guard.
        fragment = bashrc[bashrc.index('source'):]
        result = subprocess.run(['bash', '-c', fragment + '\ntest -n "$ACCENT"'],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_links_preserve_existing_directories_and_backups(self):
        function = re.search(r'link_config\(\) \{.*?^\}', INSTALLER, re.S | re.M)[0]
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            source, target = base / 'source', base / 'target'
            source.mkdir()
            target.mkdir()
            (target / 'keep').write_text('original')
            backup = base / 'target.backup'
            backup.mkdir()
            (backup / 'old').write_text('earlier backup')
            # Replace only the privilege switch; execute the real mv/ln commands.
            script = 'set -eu\nsudo() { shift 2; "$@"; }\nUSER_NAME=test\n' + function
            script += '\nlink_config "$1" "$2"\nlink_config "$1" "$2"\n'
            result = subprocess.run(['bash', '-c', script, 'test', str(source), str(target)],
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue(target.is_symlink())
            self.assertEqual(target.resolve(), source)
            self.assertEqual((backup / 'keep').read_text(), 'original')
            self.assertEqual((base / 'target.backup.~1~' / 'old').read_text(), 'earlier backup')

    def test_ocr_success_cancel_and_failure(self):
        config = (ROOT / 'niri/config.kdl').read_text()
        block = config.split('Super+Shift+D {', 1)[1].split('\n    }', 1)[0]
        args = [json.loads(s) for s in re.findall(r'"(?:\\.|[^"\\])*"', block)]
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            commands = {
                'slurp': 'test "$CASE" != cancel || exit 1; printf "0,0 10x10"',
                'grim': 'test "$CASE" != capture-fail || exit 1; printf image',
                'tesseract': 'cat >/dev/null; test "$CASE" != ocr-fail || exit 1; printf recognized',
                'wl-copy': 'cat > "$CLIPBOARD"',
            }
            for name, body in commands.items():
                executable = base / name
                executable.write_text('#!/bin/sh\n' + body + '\n')
                executable.chmod(0o755)
            clipboard = base / 'clipboard'
            for case in ('success', 'cancel', 'capture-fail', 'ocr-fail'):
                clipboard.write_text('previous')
                env = dict(os.environ, PATH=str(base) + ':' + os.environ['PATH'],
                           CASE=case, CLIPBOARD=str(clipboard))
                subprocess.run(args, env=env, capture_output=True, text=True)
                self.assertEqual(clipboard.read_text(), 'recognized' if case == 'success' else 'previous', case)


if __name__ == '__main__':
    unittest.main()
