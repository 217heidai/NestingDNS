#!/bin/sh


PROCESSES="/nestingdns/bin/adguardhome /nestingdns/bin/mosdns /nestingdns/lib/smartdns/smartdns"

status=0

for process in $PROCESSES; do
    if ! pgrep -x "$process" >/dev/null; then
        echo "ERROR: $process not running"
        status=1
    else
        echo "$process is running"
    fi
done

exit $status