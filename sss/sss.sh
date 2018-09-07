#!/bin/bash
#start all ss client

start(){
  t=${1##*\/}
  pfile=${t%%\.*}
  /usr/bin/$2 -c ${1} -f /var/run/${pfile}.pid
}

stop(){
  t=${1##*\/}
  pfile=${t%%\.*}
  kill $(cat /var/run/${pfile}.pid)
  rm -rf /var/run/${pfile}.pid
}

case $1 in
  "0") bin=start ;;
  "1") bin=stop ;;
  *) echo "err" && exit 127;;
esac

for i in `ls /etc/shadowsocks/*.json`;
do
  echo $i | grep ssr &> /dev/null && rbin='ss-redir' || rbin='ss-tunnel'
  $bin $i $rbin
done
