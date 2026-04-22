#!/bin/sh

set -eu

VARDIR="/var/canary"
mkdir -p "$VARDIR"

ETCDIR="/etc/canary"
mkdir -p "$ETCDIR"

LOGDIR="/var/log"
TRIGGERED="$VARDIR/triggered"

# Closes all the listeners and exits
die() {
	while read -r proc; do
		kill -9 "$proc" >/dev/null 2>&1 || true
	done < "$VARDIR/procs"

	rm -f "$VARDIR/procs"
	echo "$(date): Canary died." >> "$LOGDIR/canary.log"
	# Signal alive_check to stop
	touch "$TRIGGERED"
}

trap 'die' EXIT

echo "$(date): Starting canary" > "$LOGDIR/canary.log"
chmod 600 "$LOGDIR/canary.log"

rm -f "$TRIGGERED"

if [ ! -f "$ETCDIR/ports" ]; then
	echo "22" > "$ETCDIR/ports"
fi

# Start a listener on each honeypot port
true > "$VARDIR/procs"
while read -r port; do
	nc -l -k -v "$port" >> "$LOGDIR/canary.log" 2>&1 &
	echo "$!" >> "$VARDIR/procs"
done < "$ETCDIR/ports"

# Wait for any honeypot port to receive a connection.
# nc logs "Connection from" (GNU) or "connect to" (BSD) on a new connection.
# We tail the log and look for these exact phrases rather than polling.
tail -f "$LOGDIR/canary.log" | grep -qi -m 1 "connection from\|connect to"

exit 0
