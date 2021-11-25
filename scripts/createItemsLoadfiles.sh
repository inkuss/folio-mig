#!/bin/bash
# Autor: I. Kuss, hbz
# Erzeugt Ladedateien mit FOLIO-Exemplardatensätzen

usage() {
  cat <<EOF
  Erzeugt Ladedateien mit FOLIO-Exemplardatensätzen
  Beispielaufruf:        ./createItemsLoadfiles.sh -d ~/folio-mig/sample_input/items

  Optionen:
   - d [Verzeichnis] Verzeichnis mit Exemplardaten (im Format: FOLIO-JSON)
   - h              Hilfe (dieser Text)
EOF
  exit 0
  }

# Auswertung der Optionen und Kommandozeilenparameter
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "d:h?" opt; do
    case "$opt" in
    d)  directory=$OPTARG
        ;;
    h|\?) usage
        ;;
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

# Beginn der Hauptverarbeitung
if [ ! -d $directory ]; then
  echo "ERROR: ($directory) ist kein bekanntes Verzeichnis !"
  exit 0
fi

echo "Lege Ladedateien an anhand von JSON-Dateien im Verzeichnis: $directory"

inputDir=$directory
# Pakete von je max. 10000 Sätzen bauen
zaehler=0
paket_nr=0
paket_zaehler=0
# Schreibe Exemplardatensätze in eine Datei
loadfile_basename="loadfile"
loadfile=""
for item in $inputDir/*.json; do
  if [ `expr $zaehler % 10000` -eq 0 ]; then
    # Beende altes Paket
    if [ "$paket_nr" -gt 0 ]; then
      cat >> $inputDir/$loadfile <<TAIL
  ]
}
TAIL
      echo "Ladedatei $inputDir/$loadfile angelegt."
    fi
    # Beginne Neues Paket
    paket_nr=`expr $paket_nr + 1`
    echo "BEGINNE Paket Nr. $paket_nr"
    loadfile=$loadfile_basename"_"$paket_nr".js"
    echo "Erzeuge Ladedatei $inputDir/$loadfile"
    cat > $inputDir/$loadfile <<HEAD
{
  "items": [
HEAD
    paket_zaehler=0
  fi 
  if [ "$paket_zaehler" -gt 0 ]; then
    echo "," >> $inputDir/$loadfile
  fi
  zaehler=`expr $zaehler + 1`
  paket_zaehler=`expr $paket_zaehler + 1`
  # echo "Zaehler: $zaehler"
  cat $item >> $inputDir/$loadfile
done
# Beende letztes Paket
if [ "$paket_nr" -gt 0 ]; then
  cat >> $inputDir/$loadfile <<TAIL
  ]
}
TAIL
  echo "Ladedatei $inputDir/$loadfile angelegt."
fi
echo "INFO: Anzahl insgesamt paketierter Exemplardatensätze: $zaehler"
echo "INFO: Anzahl erzeugter Pakete: $paket_nr"
echo "ENDE: Pakete erzeugen"

exit 0
