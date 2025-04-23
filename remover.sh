#!/bin/bash

# Richiedi all'utente di inserire il nome della directory da cercare
read -p "Inserisci il nome della directory da cercare: " directory_da_cercare

# Controlla se il nome della directory è vuoto
if [ -z "$directory_da_cercare" ]; then
    echo "Errore: Il nome della directory da cercare non può essere vuoto."
    exit 1
fi

# Richiedi all'utente di inserire il percorso iniziale (default è "/")
read -p "Inserisci il percorso iniziale per la ricerca (premi Invio per default '/'): " percorso_iniziale

# Se l'utente non ha inserito nulla, usa "/" come default
if [ -z "$percorso_iniziale" ]; then
    percorso_iniziale="/"
fi

trovate=0

find "$percorso_iniziale" -name "$directory_da_cercare" -type d -print0 | while IFS= read -r -d $'\0' directory; do
    trovate=$((trovate + 1))
    echo "Trovata directory: $directory"

    pids=$(lsof +d "$directory" -t)
    if [ -n "$pids" ]; then
        echo "Processi che utilizzano '$directory': $pids"
        echo "Terminando forzatamente i processi per '$directory'..."
        kill -9 "$pids"
        sleep 2 # Attendi un breve periodo per la terminazione
        pids_after_kill=$(lsof +d "$directory" -t)
        if [ -n "$pids_after_kill" ]; then
            echo "ATTENZIONE: Alcuni processi non si sono chiusi:"
            echo "$pids_after_kill"
            echo "Potrebbe essere necessario terminarli manualmente."
        fi
    else
        echo "Nessun processo trovato che utilizza '$directory'."
    fi

    echo "Rimuovendo forzatamente la directory '$directory' e il suo contenuto..."
    rm -rf "$directory"
    echo "Directory '$directory' rimossa."
done

if [ "$trovate" -eq 0 ]; then
    echo "Nessuna directory '$directory_da_cercare' trovata in '$percorso_iniziale'."
fi

exit 0
