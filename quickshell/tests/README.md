Run the lifetime regression checks with:

```sh
python3 tests/run-lifetimes.py
```

Requires Python 3 and Qt 6's `qmltestrunner` (the runner currently uses the Arch
Linux path `/usr/lib/qt6/bin/qmltestrunner`).

The runner copies the production QML into a temporary directory, substituting
inert process IO, window surfaces, and desktop services. It exercises real QML
creation/destruction, provider ownership, popup routing, callback cleanup, and
ListView/image loading without starting shell commands or locking the desktop.
The existing lock-screen Column anchor warning is ignored explicitly; callback
ReferenceErrors and TypeErrors fail the lock lifetime test.

These checks do not exercise Wayland surface placement, hardware polling, or
multi-day RSS growth. Those still require a desktop session. The audio visualizer
is outside this change and these tests.
