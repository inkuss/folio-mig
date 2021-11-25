#!/bin/bash
# Autor: I. Kuss, hbz
# Anlagedatum: 23.11.2020
# Löscht einen Folio-Titelsatz (Instance)
source funktionen.sh

usage() {
  cat <<EOF
  Löscht eine Folio-Titelaufnahme (Instance).
  1. Aufruf ohne Optionen : Löscht einen Titel anhand seiner ID.
     Aufruf:                ./deleteInstance.sh instanceId
     benötigt: login.json im gleichen Verzeichnis.
     Beispielaufruf:        ./deleteInstance.sh 7433c70e-8887-550b-a048-0e421ad628f2
  2. Aufruf mit Parameteroption -f : Löscht einen Titel anahnd einer Datei im Format FOLIO-JSON. Parst Item-ID aus Datei.
     Beispielaufruf:        ./deleteInstance.sh -f ~/folio-mig/sample_input/instances/1890.json

  Optionen:
   - f [Datei]      ID wird aus Datei gelesen
   - h              Hilfe (dieser Text)
   - l [Datei]      login.json Datei mit Inhalt { "tenant" : "...", "username" : "...", "password" : "..." },
                    Standard $login_datei
   - o [OKAPI_URL]  OKAPI_URL, Default: $OKAPI
   - s              silent off (nicht still), Standard: $silent_off
   - t [TENANT]     TENANT, Default: $TENANT
   - v              verbose (gesprächig), Standard: $verbose
  
  Parameter:
    \$1 : Item-ID
  
EOF
  exit 0
  }

# Default-Werte
useFile=0
folio_json_file=""
verbose=0
silent_off=0
OKAPI=http://localhost:9130
TENANT="diku";
login_datei="login.json"

# Auswertung der Optionen und Kommandozeilenparameter
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "f:h?l:o:st:v" opt; do
    case "$opt" in
    f)  useFile=1
	folio_json_file=$OPTARG
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
id=""
if [ $useFile == 1 ]; then
  echo "Datei=$folio_json_file"
  if [ ! -f $folio_json_file ]; then
    echo "ERROR: ($folio_json_file) ist keine reguläre Datei!"
    exit 0
  fi
  id=`cat $folio_json_file | jq ".id"`
  id=$(stripOffQuotes $id)
else
  id=$1
fi
echo "Lösche Titeldatensatz id=$id"

curlopts=""
if [ $silent_off != 1 ]; then
  curlopts="$curlopts -s"
fi
if [ $verbose == 1 ]; then
  curlopts="$curlopts -v"
fi
TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json" -H "Accept: application/json" -d @$login_datei $OKAPI/authn/login | grep -i "^x-okapi-token: " )
curl $curlopts -S -X DELETE -H "$TOKEN" -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json; charset=utf-8" $OKAPI/inventory/instances/$id
echo

exit 0
