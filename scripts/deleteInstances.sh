#!/bin/bash
# Autor: I. Kuss, hbz

usage() {
  cat <<EOF
  Löscht Folio-Titeldatensätze
  Beispielaufruf:        ./deleteInstances.sh -d ~/folio-mig/sample_input/instances

  Optionen:
   - d [Verzeichnis]    Verzeichnis mit Titeldaten (Format: FOLIO-JSON)
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
for instance in $inputDir/*.json; do
  ./deleteInstance.sh -f $instance
done

exit 0
