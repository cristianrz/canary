# 🐦 Canary

Simple POSIX shell canary.

## Install

```terminal
# make install
```

## Usage

Configure the ports to listen to:

```terminal
# echo 21  >  /etc/canary/ports
# echo 22  >> /etc/canary/ports
# echo 80  >> /etc/canary/ports
# echo 443 >> /etc/canary/ports
```

Then run with:

```terminal
# canary &
```

From a remote computer you can query the canary with:

```terminal
$ curl 192.168.1.44:8321
Alive
```

But if any of the listening ports is queried:

```terminal
$ curl 192.168.1.44:80"
curl: (7) Failed to connect to localhost port 80: Connection refused
$ ssh 192.168.1.44
ssh: connect to host 192.168.1.44 port 22: Connection refused
```

Then the canary dies:

```terminal
$ curl 192.168.1.44:8321"
curl: (7) Failed to connect to localhost port 8321: Connection refused
```

Then we can check from the logs who killed it:

```terminal
# grep "Connection from" /var/log/canary.log
Ncat: Connection from 192.168.1.58:41004.
```

