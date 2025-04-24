#!/bin/bash

SCRIPT_PATH="/home/user/backup.sh"
CRONTAB_LINE="*/10 * * * * $SCRIPT_PATH"

# Funzione per verificare se la riga è presente nel crontab
is_cron_active() {
  crontab -l | grep -Fxq "$CRONTAB_LINE"
}

# Funzione per avviare il cron job
start_cron() {
  if ! is_cron_active; then
    (crontab -l ; echo "$CRONTAB_LINE") | crontab -
    echo "Cron job per il backup (ogni 10 minuti) è stato avviato."
  else
    echo "Cron job per il backup (ogni 10 minuti) è già attivo."
  fi
}

# Funzione per fermare il cron job
stop_cron() {
  if is_cron_active; then
    crontab -l | grep -v -Fx "$CRONTAB_LINE" | crontab -
    echo "Cron job per il backup (ogni 10 minuti) è stato fermato."
  else
    echo "Cron job per il backup (ogni 10 minuti) non è attivo."
  fi
}

case "$1" in
  "start")
    start_cron
    ;;
  "stop")
    stop_cron
    ;;
  *)
    echo "Usage: $0 [start|stop]"
    exit 1
    ;;
esac

exit 0
