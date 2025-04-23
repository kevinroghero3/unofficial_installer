#!/bin/bash

# Verifica se wget è installato
if ! command -v wget &> /dev/null; then
  echo "wget non è installato. Tentativo di installazione..."
  sudo apt-get update
  sudo apt-get install -y wget
  if [ $? -ne 0 ]; then
    echo "Errore durante l'installazione di wget. Lo script verrà interrotto."
    exit 1
  fi
fi

# Verifica se Firefox è già installato
if dpkg -s firefox > /dev/null 2>&1; then
  echo "Firefox è già installato. Tentativo di disinstallazione..."
  sudo apt-get remove --purge -y firefox
  if [ $? -ne 0 ]; then
    echo "Errore durante la disinstallazione di Firefox. Lo script verrà interrotto."
    exit 1
  fi
  echo "Firefox disinstallato con successo."
fi

# Crea la directory per le keyring di apt
sudo install -d -m 0755 /etc/apt/keyrings

# Scarica la chiave di firma del repository di Mozilla
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

# Verifica l'impronta digitale della chiave
expected_fingerprint="35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3"
actual_fingerprint=$(gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}')

if [ "$actual_fingerprint" == "$expected_fingerprint" ]; then
  echo "Impronta digitale della chiave verificata ($actual_fingerprint)."
else
  echo "Verifica fallita: impronta digitale ($actual_fingerprint) non corrispondente a quella prevista ($expected_fingerprint)."
  echo "Lo script verrà interrotto."
  exit 1
fi

# Aggiunge il repository di Mozilla alla lista delle sorgenti
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

# Imposta la preferenza per il repository di Mozilla
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

# Aggiorna la lista dei pacchetti e installa Firefox
sudo apt-get update && sudo apt-get install -y firefox

echo "Firefox installato con successo dal repository di Mozilla!"

exit 0
