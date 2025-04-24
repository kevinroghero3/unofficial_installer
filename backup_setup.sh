#!/bin/bash

CONTROL_BACKUP_URL="https://raw.githubusercontent.com/kevinroghero3/unofficial_tools/refs/heads/main/control_backup.sh"
BACKUP_URL="https://raw.githubusercontent.com/kevinroghero3/unofficial_tools/refs/heads/main/backup.sh"
CONTROL_BACKUP_FILE="control_backup.sh"
BACKUP_FILE="backup.sh"
RCLONE_CONFIG_FILE="/root/.config/rclone/rclone.conf" # Percorso del file di configurazione di rclone

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
else
  echo "rclone è già installato."
fi

# Scarica control_backup.sh e verifica
echo "Scaricamento di $CONTROL_BACKUP_FILE..."
wget "$CONTROL_BACKUP_URL" -O "$CONTROL_BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo "$CONTROL_BACKUP_FILE scaricato con successo."
  chmod +x "$CONTROL_BACKUP_FILE"  # Rendi eseguibile control_backup.sh
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

# Verifica se il file di configurazione di rclone esiste
if [ ! -f "$RCLONE_CONFIG_FILE" ]; then
  echo "Configurazione di rclone non trovata. Usare \"rclone config\" prima di far partire il backup automatico."
  exit 1
else
  echo "Configurazione di rclone esistente trovata."
fi

# Esegui control_backup.sh per avviare il cron job
echo "Avvio del cron job di backup..."
./"$CONTROL_BACKUP_FILE" start

exit 0
