#!/bin/sh

set -eu

PORT="8321"
VARDIR="/var/canary"
TRIGGERED="$VARDIR/triggered"

# Serve a minimal HTTP 200 response on the alive port.
# Uses a POSIX-compatible printf | nc loop instead of nc -c.
_serve() {
	while true; do
		printf 'HTTP/1.1 200 OK\r\nContent-Length: 6\r\n\r\nAlive\n' | nc -l "$PORT" >/dev/null 2>&1
	done
}

_serve &
proc="$!"

trap 'kill -9 $proc 2>/dev/null || true' EXIT

printf "Listening on port %s\n" "$PORT"

# Block until traps.sh signals death via the trigger file
while sleep 1; do
	if [ -f "$TRIGGERED" ]; then
		rm -f "$TRIGGERED"
		exit 0
	fi
done
