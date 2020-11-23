#!/bin/bash
# Autor: I. Kuss, hbz

usage() {
  cat <<EOF
  Legt Folio-Lokalsätze (Holdings) an
  Beispielaufruf:        ./createHoldings.sh -d ~/folio-mig/sample_input/holdings

  Optionen:
   - d [Verzeichnis]    Verzeichnis mit Holdings-Dateien (Format: FOLIO-JSON)
   - h                  Hilfe (dieser Text)
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
inputDir=$directory
for item in $inputDir/*.json; do
  ./createHolding.sh -f $item
done

exit 0
