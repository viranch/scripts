# script to setup firefox sync server on VPS etc

# Packages
pacman -S python2 python2-virtualenv sqlite3 mercurial make

# python preparation
cd /usr/bin
ln -sf virtualenv2 virtualenv

# setup
mkdir -p /opt/weave
cd /opt/weave
hg clone https://hg.mozilla.org/services/server-full
cd server-full
make build

# restore python's initial state
cd /usr/bin
rm -f virtualenv

# server configuration
mkdir /opt/weave/data /var/log/weave
sed -i 's/\/tmp\/sync-error\.log/\/var\/log\/weave\/sync-error.log/g' development.ini
sed -i 's/tmp\/test\.db/opt\/weave\/data\/sync.db' etc/sync.conf
sed -i 's/quota_size =.*$/quota_size = 25600/g' etc/sync.conf
sed -i 's/^.*fallback_node =.*$/fallback_node = http:\/\/localhost:5000\//g' etc/sync.conf

# unprivileged user
groupadd weave
useradd -d /opt/weave -g weave -r -s /bin/bash sync
chown -R sync:weave /opt/weave/*
chown -R sync:weave /var/log/weave

# auto start server at boot time
cat << EOF > /etc/rc.d/mozillaweave
#!/bin/bash

RUNDIR=/var/run/weave
DAEMON=/opt/weave/bin/python
PIDFILE=/var/run/weave.pid
MESSAGELOG=/var/log/weave/sync-messages.log

. /etc/rc.conf
. /etc/rc.d/functions

PID=``pidof -x -o %PPID paster``
case "$$1" in
  start)
    stat_busy "Starting Mozilla Sync Server"
    [ -d $$RUNDIR ] || mkdir $$RUNDIR
    [ -z "$$PID" ] && su sync -c "cd /opt/weave/server-full && bin/paster serve development.ini &>$$MESSAGELOG &"
    if [ $$? -gt 0 ]; then
      stat_fail
    else
      PID=``pidof -x -o %PPID paster``
      echo $$PID >$$PIDFILE
      add_daemon weave
      stat_done
    fi
    ;;
  stop)
    stat_busy "Stopping Mozilla Sync Server"
    [ ! -z "$$PID" ]  && kill $$PID &>/dev/null
    if [ $$? -gt 0 ]; then
      stat_fail
    else
      rm_daemon weave
      stat_done
    fi
    ;;
  restart)
    $$0 stop
    $$0 start
    ;;
  *)
    echo "usage: $$0 {start|stop|restart}"  
esac
exit 0
EOF
chmod 755 /etc/rc.d/mozillaweave
sed -i 's/DAEMONS=(\(.*\))/DAEMONS=(\1 mozillaweave)/g' /etc/rc.conf
sudo rc.d start mozillaweave
