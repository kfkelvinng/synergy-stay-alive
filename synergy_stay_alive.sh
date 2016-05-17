#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LOG="${DIR}/$(basename ${BASH_SOURCE[0]}).log"

run() {

  if arp -a | grep '(192.168.1.1)' | md5sum | grep cbf645c49fb631ced617c459a50169f5; then
    log "At Home..."
  else
    exit 0
  fi

  if netstat -apn 2>/dev/null | grep 24800 | tee -a "$LOG" | grep ESTABLISHED && pgrep synergyc ; then
    log "Running..."
    exit 0
  fi

  log "Killing..."
  ps -ef | grep synergyc
  pkill -9 synergyc
  if pgrep synergyc; then
    log "Fail to kill..."
    exit 1
  fi

  for dest in kelvin-pc 192.168.1.10{0..9}; do
    log "Connecting to $dest"
    if nc -z $dest 24800; then
      syn kelvin-pc
      exit 0
    fi
  done
 }

syn() {
  /usr/bin/synergyc -f --no-tray --debug INFO --name kelvin-ThinkPad-Edge-E531 $1:24800 >> "$LOG" &
}

log() {
    echo $(date --rfc-3339=ns) $@ >> "$LOG"
}

run >> "$LOG" 2>&1
