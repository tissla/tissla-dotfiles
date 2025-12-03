#!/bin/bash

URL="$1"

shift

exec setsid firefox --app="$URL" "$@"
