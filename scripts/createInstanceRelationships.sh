#!/bin/bash
# Autor: I. Kuss, hbz
# Legt Folio-Instanzbeziehungen an

usage() {
  cat <<EOF
  Legt Folio-Instanzbeziehungen an
  Beispielaufruf:        ./createInstanceRelationships.sh -d ~/folio-mig/sample_input/instanceRelationships

  Optionen:
   - d [Verzeichnis]    Verzeichnis mit Instanzbeziehungen (Format: FOLIO-JSON)
   - h                  Hilfe (dieser Text)
   - t [TENANT]     TENANT, Default: $TENANT
EOF
  exit 0
  }

# Default-Werte
TENANT="diku"

# Auswertung der Optionen und Kommandozeilenparameter
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "d:h?t:" opt; do
    case "$opt" in
    d)  directory=$OPTARG
        ;;
    h|\?) usage
        ;;
    t)  TENANT=$OPTARG
        ;;
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

# Beginn der Hauptverarbeitung
echo "BEGINN Erzeuge FOLIO-Instanzbeziehungen: " `date`
inputDir=$directory
for IR in $inputDir/*.json; do
  ./createInstanceRelationship.sh -s -v -t $TENANT -f $IR
done
echo "ENDE Erzeuge FOLIO-Instanzbeziehungen: " `date`

exit 0
