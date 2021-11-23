#!/bin/bash
# Autor: I. Kuss, hbz
source funktionen.sh

usage() {
  cat <<EOF
  Löscht Folio-Exemplare
  Beispielaufrufe:        ./deleteItems.sh -d ~/folio-mig/sample_input/items
                          ./deleteItems.sh -f ~/folio-mig/sample_input/items/createItems.json

  Optionen:
   - d [Verzeichnis]    Verzeichnis mit Item-Dateien (Format: FOLIO-JSON)
   - f [Datei]          Datei im Format JSON mit einer Liste von IDs im Format
                        {
                          "items": [
                            {
                              "id" : "0bcf0796-5974-52fa-be23-d329d998d157",
                              ... /* weitere Einträge, die hier irrelevant sind */
                            }
                          ]
                        }
   - h                  Hilfe (dieser Text)
EOF
  exit 0
  }

# Default-Werte
useFile=0
useDirectory=0

# Auswertung der Optionen und Kommandozeilenparameter
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "d:f:h?" opt; do
    case "$opt" in
    d)  useDirectory=1
        directory=$OPTARG
        ;;
    f)  useFile=1
        file=$OPTARG
        ;;
    h|\?) usage
        ;;
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

# Beginn der Hauptverarbeitung
if [ $useFile == 1 ]; then
  echo "Datei=$file"
  if [ ! -f $file ]; then
    echo "ERROR: ($file) ist keine reguläre Datei!"
    exit 0
  fi
  for id in `cat $file | jq ".items[].id"`; do
    id=$(stripOffQuotes $id)
    echo "Deleting ID: $id ..."
    # hier dann auch wirklich löschen
    echo "WARN: hier dann auch wirklich löschen..."
    # ./deleteItem.sh $id
  done
elif [ $useDirectory ==1 ]; then
  for item in $directory/*.json; do
    ./deleteItem.sh -f $item
  done
else
  echo "ERROR: Neither a file nor a directory was specified ! Nothing done."
fi

exit 0
