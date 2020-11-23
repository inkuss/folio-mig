#!/bin/bash
# Autor: I. Kuss, hbz
# Anlagedatum: 23.11.2020
# Legt ein Folio-Exemplar an.
source funktionen.sh

usage() {
  cat <<EOF
  Legt ein Folio-Exemplar an.
  Anlage anahnd einer Datei im Format FOLIO-JSON.
  Beispielaufruf:        ./createItem.sh -f ~/folio-mig/sample_input/items/4711.json

  Optionen:
   - f [Datei]      Exemplardaten im Format FOLIO-JSON
   - h              Hilfe (dieser Text)
   - l [Datei]      login.json Datei mit Inhalt { "tenant" : "...", "username" : "...", "password" : "..." },
                    Standardwert: $login_datei
   - o [OKAPI_URL]  OKAPI_URL, Default: $OKAPI
   - s              silent off (nicht still), Standardwert: $silent_off
   - t [TENANT]     TENANT, Default: $TENANT
   - v              verbose (gesprächig), Standardwert: $verbose
EOF
  exit 0
  }

# Default-Werte
folio_json_datei=""
verbose=0
silent_off=0
OKAPI=https://folio-hbz1.hbz-nrw.de/okapi
TENANT="diku";
login_datei="login.json"

# Auswertung der Optionen und Kommandozeilenparameter
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "f:h?l:o:st:v" opt; do
    case "$opt" in
    f)  folio_json_datei=$OPTARG
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
if [ ! -f $folio_json_datei ]; then
  echo "ERROR: ($folio_json_datei) ist keine reguläre Datei !"
  exit 0
fi

echo "Lege Exemplar an anhand von Datei: $folio_json_datei"

curlopts=""
if [ $silent_off != 1 ]; then
  curlopts="$curlopts -s"
fi
if [ $verbose == 1 ]; then
  curlopts="$curlopts -v"
fi

TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json" -H "Accept: application/json" -d @$login_datei $OKAPI/authn/login | grep -i "^x-okapi-token: " )
curl $curlopts -S -X POST -H "$TOKEN" -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json; charset=utf-8" -H "Accept: application/json" -d \@$folio_json_datei $OKAPI/item-storage/items
echo

exit 0
