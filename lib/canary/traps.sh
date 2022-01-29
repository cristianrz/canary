#!/bin/sh

set -eu

VARDIR="/var/canary"
mkdir -p "$VARDIR"

ETCDIR="/etc/canary"
mkdir -p "$ETCDIR"

LOGDIR="/var/log"

# Closes all the listeners and exists
die() {
	# Kill all honeypot ports
	while read -r proc; do
		kill -9 "$proc" >/dev/null 2>&1 || true
	done < "$VARDIR/procs"

	rm -f "$VARDIR/procs" "$VARDIR/alive"
	echo "$(date): Canary died." >> "$LOGDIR/canary.log"
}

trap 'die' EXIT

echo "$(date): Starting canary" > "$LOGDIR/canary.log"

touch "$VARDIR/alive"

if [ ! -f "$ETCDIR/ports" ]; then
	echo "22" > "$ETCDIR/ports"
fi

while read -r port; do
	nc -k -v -l "$port" >> "$LOGDIR/canary.log" 2>&1 &
	echo "$!" >> "$VARDIR/procs"
	# echo "listening on port $port"
done < "$ETCDIR/ports"

while sleep 1; do
	if grep -qi conn "$LOGDIR/canary.log"; then
		exit 0
	fi
done
