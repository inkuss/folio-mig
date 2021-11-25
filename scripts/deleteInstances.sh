#!/bin/bash
# Autor: I. Kuss, hbz
source funktionen.sh

usage() {
  cat <<EOF
  Löscht Folio-Titeldatensätze
  Beispielaufrufe:       ./deleteInstances.sh -d ~/folio-mig/sample_input/instances
                         ./deleteInstances.sh -f ~/folio-mig/sample_input/instances/createInstances.json

  Optionen:
   - d [Verzeichnis]    Verzeichnis mit Titeldaten (Format: FOLIO-JSON)
   - f [Datei]          Datei im Format JSON mit einer Liste von IDs im Format
                        {
                          "instances": [
                            {
                              "id" : "0bcf0796-5974-52fa-be23-d329d998d157",
                              ... /* weitere Einträge, die hier irrelevant sind */
                            }
                          ]
                        }
   - h                  Hilfe (dieser Text)
   - t [TENANT]         TENANT, Default: $TENANT
EOF
  exit 0
  }

# Default-Werte
useFile=0
useDirectory=0
TENANT="diku"

# Auswertung der Optionen und Kommandozeilenparameter
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "d:f:h?t:" opt; do
    case "$opt" in
    d)  useDirectory=1
        directory=$OPTARG
        ;;
    f)  useFile=1
        file=$OPTARG
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
echo "BEGINN Deleting instance records:" `date`
zaehler=0
if [ $useFile == 1 ]; then
  echo "Datei=$file"
  if [ ! -f $file ]; then
    echo "ERROR: ($file) ist keine reguläre Datei!"
    exit 0
  fi
  for id in `cat $file | jq ".instances[].id"`; do
    zaehler=`expr $zaehler + 1`
    id=$(stripOffQuotes $id)
    echo "Deleting ID: $id ..."
    ./deleteInstance.sh -t $TENANT $id
  done
elif [ $useDirectory ==1 ]; then
  for instance in $directory/*.json; do
    zaehler=`expr $zaehler + 1`
    ./deleteInstance.sh -t $TENANT -f $instance
  done
else
  echo "ERROR: Neither a file nor a directory was specified ! Nothing done." 
fi
echo "Number of instance records that have been deleted: $zaehler"
echo "ENDE Deleting instance records:" `date`

exit 0
