#!/bin/bash
# Autor: I. Kuss, hbz
# 26.11.2021
# Löscht Folio-Exemplare
source funktionen.sh

usage() {
  cat <<EOF
  Löscht Folio-Exemplare
  Beispielaufrufe:        ./deleteItems.sh -t mytenant -d ~/folio-mig/sample_input/items
                          ./deleteItems.sh -t mytenant -f ~/folio-mig/sample_input/items/createItems.json
                          ./deleteItems.sh -a

  Optionen:
   - a                  Löscht alle Exemplare (für diesen Mandanten)
   - d [Verzeichnis]    Verzeichnis mit Exemplar-Dateien (Format: FOLIO-JSON)
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
   - l [Datei]      login.json Datei mit Inhalt { "tenant" : "...", "username" : "...", "password" : "..." },
                    Standard $login_datei
   - o [OKAPI_URL]  OKAPI_URL, Default: $OKAPI
   - s              silent off (nicht still), Standard: $silent_off
   - t [TENANT]         TENANT, Default: $TENANT
   - v              verbose (gesprächig), Standard: $verbose
EOF
  exit 0
  }

# Default-Werte
deleteAll=0
useFile=0
useDirectory=0
verbose=0
silent_off=0
OKAPI=http://localhost:9130
TENANT="diku";
login_datei="login.json"

# Auswertung der Optionen und Kommandozeilenparameter
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "ad:f:h?l:o:st:v" opt; do
    case "$opt" in
    a)  deleteAll=1
        ;;
    d)  useDirectory=1
        directory=$OPTARG
        ;;
    f)  useFile=1
        file=$OPTARG
        ;;
    h|\?) usage
        ;;
    l)  login_datei=$OPTARG
        ;;
    o)  OKAPI=$OPTARG
        ;;
    s)  silent_off=1
        ;;
    t)  TENANT=$OPTARG
        ;;
    v)  verbose=1
        ;;
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

# Beginn der Hauptverarbeitung
if [ $deleteAll == 1 ]; then
  curlopts=""
  if [ $silent_off != 1 ]; then
    curlopts="$curlopts -s"
  fi
  if [ $verbose == 1 ]; then
    curlopts="$curlopts -v"
  fi
  TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json" -H "Accept: application/json" -d @$login_datei $OKAPI/authn/login | grep -i "^x-okapi-token: " )
  curl $curlopts -S -X DELETE -H "$TOKEN" -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json; charset=utf-8" $OKAPI/item-storage/items
  echo
elif [ $useFile == 1 ]; then
  echo "Datei=$file"
  if [ ! -f $file ]; then
    echo "ERROR: ($file) ist keine reguläre Datei!"
    exit 0
  fi
  for id in `cat $file | jq ".items[].id"`; do
    id=$(stripOffQuotes $id)
    echo "Deleting ID: $id ..."
    ./deleteItem.sh -t $TENANT $id
  done
elif [ $useDirectory == 1 ]; then
  for item in $directory/*.json; do
    ./deleteItem.sh -t $TENANT -f $item
  done
else
  echo "ERROR: Neither a file nor a directory was specified ! Nothing done."
fi

exit 0
