#!/bin/bash

URL="$1"

shift

exec setsid google-chrome-stable --app="$URL" "$@"
