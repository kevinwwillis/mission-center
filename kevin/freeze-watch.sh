#!/bin/bash
# Records evidence when Mission Center's window freezes (TASK-1.3.2).
#
# Every 5 s it asks the app's main loop a D-Bus question (org.gtk.Actions.List
# is answered on the GTK main thread). After 3 missed answers in a row it saves:
# stack traces of every thread (sudo gdb attach, a few seconds' pause), memory,
# swap, GPU memory and the last journal lines. One capture per freeze.
#
# Usage: kevin/freeze-watch.sh [app-id]   (default: the official Flathub app)
# Runs detached:  systemd-run --user --unit=mc-freeze-watch kevin/freeze-watch.sh
set -u
APP_ID="${1:-io.missioncenter.MissionCenter}"
OBJ="/$(echo "$APP_ID" | tr . /)"
OUT="$HOME/.local/state/mission-center-watch/freezes"
mkdir -p "$OUT"
misses=0
captured=0
while true; do
  # The app process of this exact app ID (not another Mission Center build):
  # the sandbox's child-pid is bwrap, and missioncenter is its direct child.
  sandbox=$(flatpak ps --columns=child-pid,application | awk -v id="$APP_ID" '$2 == id {print $1; exit}')
  pid=""
  [ -n "$sandbox" ] && pid=$(pgrep -x missioncenter -P "$sandbox" | head -1)
  if [ -z "$pid" ]; then misses=0; captured=0; sleep 5; continue; fi
  if timeout 6 gdbus call --session --dest "$APP_ID" --object-path "$OBJ" \
       --method org.gtk.Actions.List --timeout 4 >/dev/null 2>&1; then
    if [ "$captured" = 1 ]; then
      echo "$(date '+%F %T %Z') pid $pid responding again" >> "$OUT/events.log"
    fi
    misses=0; captured=0
  else
    misses=$((misses + 1))
    echo "$(date '+%F %T %Z') pid $pid no answer ($misses)" >> "$OUT/events.log"
    if [ "$misses" -ge 3 ] && [ "$captured" = 0 ]; then
      d="$OUT/$(date +%Y%m%d-%H%M%S)-pid$pid"
      mkdir -p "$d"
      { date '+%F %T %Z'; free -m; cat /proc/pressure/memory; } > "$d/memory.txt" 2>&1
      grep -E 'State|VmRSS|VmSwap|Threads' "/proc/$pid/status" > "$d/proc-status.txt" 2>&1
      for t in /proc/"$pid"/task/*; do echo "$(basename "$t") $(cat "$t/comm") $(cat "$t/stat" | awk '{print $3}') wchan=$(cat "$t/wchan" 2>/dev/null)"; done > "$d/threads.txt" 2>&1
      nvidia-smi > "$d/nvidia-smi.txt" 2>&1
      timeout 60 sudo gdb -p "$pid" -batch -ex "set pagination off" -ex "thread apply all bt" > "$d/backtrace.txt" 2>&1
      journalctl --since "-3min" --no-pager > "$d/journal.txt" 2>&1
      echo "$(date '+%F %T %Z') pid $pid frozen: captured $d" >> "$OUT/events.log"
      curl -s -H "Title: Mission Center froze" -d "Freeze captured at $(date '+%H:%M ET'); evidence in $d" \
        https://kevin-labhost.tailb77d0f.ts.net:8450/alerts >/dev/null 2>&1 || true
      captured=1
    fi
  fi
  sleep 5
done
