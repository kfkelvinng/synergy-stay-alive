#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LOG="${DIR}/log.log"

run() {

  if /usr/sbin/arp -a | grep '(192.168.1.1)' | md5sum | egrep 'cbf645c49fb631ced617c459a50169f5|a11d00ddd31413fd44a8149bb2e58753|45f677548faff833bf981b296786d824'; then
    log "At Home..."
  else
    log "Not at Home..."
    exit 0
  fi

  if netstat -apn 2>/dev/null | grep 24800 | tee -a "$LOG" | grep ESTABLISHED && pgrep synergyc ; then
    log "Already alive..."
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
    log "Trying $dest"
    if nc -z $dest 24800; then
      log "Connecting $dest"
      syn $dest
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

(
    flock -n 9 || ( log "flock"; exit 1 )
    run >> "$LOG" 2>&1
) 9>$DIR/lock

