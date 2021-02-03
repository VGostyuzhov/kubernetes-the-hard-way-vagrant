#!/bin/bash

apt-get update
#apt-get -y dist-upgrade
apt-get install -y heartbeat

cat >/etc/ha.d/ha.cf <<EOF
debugfile /var/log/ha-debug
logfile /var/log/ha-log
logfacility     local0
keepalive 2
deadtime 30
initdead 120
udpport 694
auto_failback off
ucast $(ip -4 --oneline addr | grep '192\.168\.100\.' | cut -d' ' -f2) 192.168.100.10
ucast $(ip -4 --oneline addr | grep '192\.168\.100\.' | cut -d' ' -f2) 192.168.100.11
node    controller-0
node    controller-1
EOF

cat >/etc/ha.d/haresources <<EOF
controller-0 IPaddr::192.168.100.100/24/$(ip -4 --oneline addr | grep '192\.168\.100\.' | cut -d' ' -f2)
EOF

cat >/etc/ha.d/authkeys <<EOF
auth 1
1 md5 just-for-learning
EOF
chmod 600 /etc/ha.d/authkeys

service heartbeat restart
