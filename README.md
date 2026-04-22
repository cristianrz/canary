# 🐦 Canary

A honeypot that signals intrusion by dying.

Canary listens on a set of decoy ports and exposes a health endpoint.
As long as none of the decoy ports are touched, the health endpoint
returns `Alive`. The moment any decoy port receives a connection,
Canary shuts everything down — the health endpoint goes silent, and
you know someone is in your network.

## Dependencies

- `nc` (netcat)

## Install

```sh
sudo make install
```

## Usage

**1. Configure the decoy ports:**

```sh
echo 21  >  /etc/canary/ports
echo 22  >> /etc/canary/ports
echo 80  >> /etc/canary/ports
echo 443 >> /etc/canary/ports
```

**2. Start the canary:**

```sh
sudo canary &
```

**3. Poll the health endpoint from a monitoring system:**

```sh
$ curl 192.168.1.44:8321
Alive
```

**4. If a decoy port is touched:**

```sh
$ ssh 192.168.1.44
ssh: connect to host 192.168.1.44 port 22: Connection refused
```

The canary dies — the health endpoint goes silent:

```sh
$ curl 192.168.1.44:8321
curl: (7) Failed to connect to 192.168.1.44 port 8321: Connection refused
```

**5. Check the logs to see who triggered it:**

```sh
$ grep "Connection from" /var/log/canary.log
Ncat: Connection from 192.168.1.58:41004.
```

## Starting on boot

Add a systemd unit or a cron `@reboot` entry:

```
@reboot root /usr/local/bin/canary &
```

## How it works

Canary runs two processes:

- **traps** — listens on each decoy port with `nc`. Watches the log
  for a connection event and exits when one is detected, triggering
  cleanup of all listeners.
- **alive_check** — serves `Alive` on port `8321`. Watches for the
  death signal from traps and stops serving when it arrives.

The parent ties their lifetimes together — if either exits, the other
is killed.

## License

BSD 3-Clause
