#!/bin/bash
# Autor: I. Kuss, hbz
# Legt FOLIO-Lokaldatensätze an

usage() {
  cat <<EOF
  Legt Folio-Lokalsätze (Holdings) an
  Beispielaufruf:        ./createHoldings.sh -d ~/folio-mig/sample_input/holdings

  Optionen:
   - d [Verzeichnis]    Verzeichnis mit Holdings-Dateien (Format: FOLIO-JSON)
   - h                  Hilfe (dieser Text)
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

echo "Lege Lokaldatensätze an anhand von JSON-Dateien im Verzeichnis: $directory"

curlopts=""
if [ $silent_off != 1 ]; then
  curlopts="$curlopts -s"
fi
if [ $verbose == 1 ]; then
  curlopts="$curlopts -v"
fi

inputDir=$directory
zaehler=1
# Schreibe mal 100 Titeldatensätze in eine Datei
cat > $inputDir/createHoldings.json <<HEAD
{
  "holdings": [
HEAD
for holding in $inputDir/*.json; do
  echo "Zaehler: $zaehler"
  cat $holding >> $inputDir/createHoldings.json
  zaehler=`expr $zaehler + 1`
  if [ "$zaehler" -gt 100 ]; then
    break
  fi
  echo "," >> $inputDir/createHoldings.json
done
cat >> $inputDir/createHoldings.json <<TAIL
  ]
}
TAIL
echo "Ladedatei $inputDir/createHoldings.json angelegt."
echo "WARNUNG: Anzahl Lokaldatensätze wurde auf 100 begrenzt !!"

# Use a POST to  /holdings-storage/batch/synchronous
TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json" -H "Accept: application/json" -d @$login_datei $OKAPI/authn/login | grep -i "^x-okapi-token: " )
curl $curlopts -S -X POST -H "$TOKEN" -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json; charset=utf-8" -H "Accept: application/json" -d \@$inputDir/createHoldings.json $OKAPI/holdings-storage/batch/synchronous
echo

exit 0
