#!/bin/sh

set -eu

PORT="8321"

response="echo 'HTTP/1.1 200 OK

Alive'"

nc -c "$response" -k -l 8321 >/dev/null 2>&1 &
proc="$!"

trap 'kill -9 $proc' EXIT

printf "Listening on port %s\n" "$PORT"

while sleep 1; do
	if [ ! -f /var/canary/alive ]; then
		exit 0
	fi
done
