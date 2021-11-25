#!/bin/bash
# Autor: I. Kuss, hbz
# Legt FOLIO-Exemplardatensätze anhand von Ladedateien an

usage() {
  cat <<EOF
  Legt Folio-Exemplardatensätze an
  Beispielaufruf:        ./createItems.sh -d ~/folio-mig/sample_input/items

  Optionen:
   - d [Verzeichnis] Verzeichnis mit Ladedateien für Exemplardaten (Format: FOLIO-JSON)
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
verbose=0
silent_off=0
OKAPI=http://localhost:9130
TENANT="diku";
login_datei="login.json"

# Auswertung der Optionen und Kommandozeilenparameter
OPTIND=1         # Reset in case getopts has been used previously in the shell.
while getopts "d:h?l:o:st:v" opt; do
    case "$opt" in
    d)  directory=$OPTARG
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
if [ ! -d $directory ]; then
  echo "ERROR: ($directory) ist kein bekanntes Verzeichnis !"
  exit 0
fi

echo "Lege Titeldatensätze an anhand von Ladedateien im Verzeichnis: $directory"

curlopts=""
if [ $silent_off != 1 ]; then
  curlopts="$curlopts -s"
fi
if [ $verbose == 1 ]; then
  curlopts="$curlopts -v"
fi

TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json" -H "Accept: application/json" -d @$login_datei $OKAPI/authn/login | grep -i "^x-okapi-token: " )
cd $directory
loadfile_basename="loadfile"
for loadfile in $loadfile_basename"_"*".js"; do
  echo "Ladedatei gefunden: $loadfile"
  # Use a POST to  /items-storage/batch/synchronous
  echo "BEGINN Laden :" `date`
  curl $curlopts -S -X POST -H "$TOKEN" -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json; charset=utf-8" -H "Accept: application/json" -d \@$directory/$loadfile $OKAPI/item-storage/batch/synchronous
  echo "ENDE Laden :" `date`
done
exit 0
