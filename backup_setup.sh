#!/bin/bash

CONTROL_BACKUP_URL="https://raw.githubusercontent.com/kevinroghero3/unofficial_tools/refs/heads/main/control_backup.sh"
BACKUP_URL="https://raw.githubusercontent.com/kevinroghero3/unofficial_tools/refs/heads/main/backup.sh"
CONTROL_BACKUP_FILE="control_backup.sh"
BACKUP_FILE="backup.sh"

# Funzione per verificare se un comando è disponibile
command_exists () {
  command -v "$1" >/dev/null 2>&1
}

# Verifica se rclone è installato
if ! command_exists rclone; then
  echo "rclone non è installato."
  echo "Avvio l'installazione di rclone..."
  sudo -v ; curl https://rclone.org/install.sh | sudo bash
  echo "Installazione di rclone completata."
  echo "Ora verrà avviata la configurazione di rclone."
  rclone config
fi

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
