#!/bin/bash

set -euo pipefail

apt-get install -y net-tools

case "$(hostname)" in
worker-0)
  route add -net 10.21.0.0/16 gw 192.168.100.21 2> /dev/null
  ;;
worker-1)
  route add -net 10.20.0.0/16 gw 192.168.100.20 2> /dev/null
  ;;
*)
  route add -net 10.20.0.0/16 gw 192.168.100.20 2> /dev/null
  route add -net 10.21.0.0/16 gw 192.168.100.21 2> /dev/null
  ;;
esac