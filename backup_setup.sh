#!/bin/bash

CONTROL_BACKUP_URL="https://raw.githubusercontent.com/kevinroghero3/unofficial_tools/refs/heads/main/control_backup.sh"
BACKUP_URL="https://raw.githubusercontent.com/kevinroghero3/unofficial_tools/refs/heads/main/backup.sh"
CONTROL_BACKUP_FILE="control_backup.sh"
BACKUP_FILE="backup.sh"

# Scarica control_backup.sh e verifica
echo "Scaricamento di $CONTROL_BACKUP_FILE..."
wget "$CONTROL_BACKUP_URL" -O "$CONTROL_BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo "$CONTROL_BACKUP_FILE scaricato con successo."
  chmod +x "$CONTROL_BACKUP_FILE"
else
  echo "Errore durante il download di $CONTROL_BACKUP_FILE."
  exit 1
fi

# Scarica backup.sh e verifica
echo "Scaricamento di $BACKUP_FILE..."
wget "$BACKUP_URL" -O "$BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo "$BACKUP_FILE scaricato con successo."
  chmod +x "$BACKUP_FILE"
else
  echo "Errore durante il download di $BACKUP_FILE."
  exit 1
fi

# Esegui control_backup.sh per avviare il cron job
echo "Avvio del cron job di backup..."
./"$CONTROL_BACKUP_FILE" start

exit 0
