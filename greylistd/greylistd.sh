#!/bin/bash

client=/usr/bin/greylist
daemon=/usr/sbin/greylistd
rundir=/var/run/greylistd
datadir=/var/lib/greylistd
pidfile=$rundir/pid
socket=$rundir/socket
user=greylist
group=greylist

. /etc/rc.conf
. /etc/rc.d/functions

# See if the daemon is present
test -x "$daemon" || exit 0

# Make sure /var/run/greylistd exists (/var/run may be a tmpfs)
test -d "$rundir" || {
	mkdir -p "$rundir"
	chown "$user:$group" "$rundir"
}

case "$1" in
    start)
	stat_busy "Starting Greylistd"

	if [ -e "$socket" ]
	then
	    echo "$0:"
	    echo "  Another instance of \`${daemon##*/}' seems to be running."
	    echo "  If this is not the case, please remove \"$socket\"."
            stat_fail
	    exit 1
	fi

	start-stop-daemon --start --background \
	    --chuid "$user" \
	    --pidfile "$pidfile" --make-pidfile \
	    --exec "$daemon"
        add_daemon greylistd
        stat_done
	;;

    stop)
	stat_busy "Stopping Greylistd"
	start-stop-daemon --stop --pidfile "$pidfile" &&
	    rm -f "$pidfile"
        rm_daemon greylistd
        stat_done
	;;

    reload|force-reload)
	"$client" reload
	;;

    status)
	"$client" stats
	;;

    restart)
	$0 stop
	sleep 2
	$0 start
	;;

    *)
	echo "Usage: $0 {start|stop|restart|reload|force-reload|status}" >&2
	exit 1
	;;
esac

exit 0

