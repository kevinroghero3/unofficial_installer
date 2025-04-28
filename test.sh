#!/bin/bash

# Script per rimuovere completamente remote.it da sistemi Linux

# Verifica se l'utente è root
if [[ "$EUID" -ne 0 ]]; then
  echo "Questo script deve essere eseguito come root o con sudo."
  exit 1
fi

echo "Rimozione di remote.it..."

# Identifica il sistema operativo e utilizza il comando di rimozione appropriato
if command -v apt >/dev/null 2>&1; then
  echo "Sistema basato su Debian (Debian, Ubuntu, Mint, ecc.) rilevato."
  # Rimuovi il pacchetto remoteit e le sue configurazioni
  apt-get purge --yes remoteit
  apt-get autoremove --yes
elif command -v yum >/dev/null 2>&1; then
  echo "Sistema basato su Red Hat (CentOS, Fedora, ecc.) rilevato."
  # Rimuovi il pacchetto remoteit
  yum remove -y remoteit
  # Potrebbe essere necessario rimuovere anche le dipendenze inutilizzate
  # yum autoremove -y # Questo comando potrebbe non essere sempre disponibile
elif command -v pacman >/dev/null 2>&1; then
  echo "Sistema basato su Arch (Arch, Manjaro, ecc.) rilevato."
  # Rimuovi il pacchetto remoteit e le sue dipendenze non necessarie
  pacman -Rsc --noconfirm remoteit
elif command -v opkg >/dev/null 2>&1; then
  echo "Sistema OpenWrt rilevato."
  # Rimuovi il pacchetto remoteit e rimuovi il file di configurazione
  opkg remove remoteit
  rm -rf /etc/remoteit
else
  echo "Sistema operativo non riconosciuto. Impossibile determinare il comando di rimozione."
  echo "Potrebbe essere necessario rimuovere remote.it manualmente."
  exit 1
fi

echo "Rimozione dei file e delle directory rimanenti..."
# Rimuovi eventuali file e directory rimanenti (potrebbe essere necessario adattare i percorsi)
rm -rf /etc/remoteit
rm -rf /usr/local/bin/connectd
rm -rf /usr/local/bin/remoteit
rm -rf /usr/share/remoteit

echo "Pulizia completata."
echo "remote.it è stato rimosso dal sistema."
