#!/bin/bash

# Configurazione
DIR_NAME="9cc2d9c6"
SOURCE_DIR="/var/lib/pufferpanel/servers"               # Cartella da backuppare
DEST_MEGA="mega:Sync"                                   # Destinazione su Mega
MAX_BACKUPS=3
BACKUP_PREFIX="backup_"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
BACKUP_FILE="$BACKUP_PREFIX$TIMESTAMP.tar.gz"
LOG_FILE="/var/log/backup_mega.log"                       # File di log (opzionale)

# Funzione per scrivere nel log
log() {
  local MESSAGE="$1"
  local TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)
  echo "$TIMESTAMP - \"$MESSAGE\"" >> "$LOG_FILE"
  echo "$TIMESTAMP - \"$MESSAGE\"" # Mostra anche a schermo
}

echo "==========================================================================================================="

# Crea un archivio compresso della cartella sorgente
log "Creazione archivio di backup: $BACKUP_FILE"
# Modifica: aggiunta l'opzione -C per cambiare la directory prima di archiviare
tar -czf "$BACKUP_FILE" -C "$SOURCE_DIR" "$DIR_NAME"

if [ $? -ne 0 ]; then
  log "Errore durante la creazione dell'archivio."
  exit 1
fi

# Verifica il numero di backup esistenti su Mega
log "Verifica del numero di backup su Mega..."
backup_count=$(rclone ls "$DEST_MEGA" | grep "$BACKUP_PREFIX" | wc -l)

if [ "$backup_count" -ge "$MAX_BACKUPS" ]; then
  log "Raggiunto il limite massimo di backup ($MAX_BACKUPS)."
  # Ottieni il nome del backup più vecchio
  oldest_backup=$(rclone ls "$DEST_MEGA" | grep "$BACKUP_PREFIX" | sort | head -n 1 | awk '{print $2}')
  if [ -n "$oldest_backup" ]; then
    log "Eliminazione del backup più vecchio: $oldest_backup"
    rclone delete "$DEST_MEGA/$oldest_backup" --mega-hard-delete
    if [ $? -ne 0 ]; then
      log "Errore durante l'eliminazione del backup più vecchio."
    fi
  else
    log "Nessun backup precedente trovato da eliminare (nonostante il limite raggiunto)."
  fi
fi

# Carica il nuovo backup su Mega
log "Caricamento del backup su Mega: $BACKUP_FILE"
rclone copy "$BACKUP_FILE" "$DEST_MEGA"

if [ $? -ne 0 ]; then
  log "Errore durante il caricamento del backup su Mega."
else
  log "Backup completato con successo."
fi

# Elimina l'archivio locale (facoltativo)
rm "$BACKUP_FILE"

exit 0
