#!/bin/bash
# Autor: Ingolf Kuss (hbz NRW)
# Anlagedatum: 26.11.2021
# Beschreibung: Löscht Folio-Lokaldatensätze (Holdings) aus FOLIO Inventory Holdings
source funktionen.sh

usage() {
  cat <<EOF
  Löscht Folio-Lokalsätze (Holdings)
  Beispielaufrufe:        ./deleteHoldings.sh -t mytenant -l login.mytenant.json -d /usr/folio/data-migration/migration_repo_template/iterations/test_iteration/results -f folio_holdings_transform_mfhd.json > deleteHoldings.log
                          ./deleteHoldings.sh -t mytenant -l login.mytenant.json -d ~/folio-mig/sample_input/holdings # Löscht alle IDs in allen Dateien in diesem Verzeichnis !!
                          ./deleteHoldings.sh -t mytenant -l login.mytenant.json -o http://mytenant/okapi -a  # Löscht alle Bestandsdatensätze !!!

  Optionen:
   - a                  Löscht alle Holdings (für diesen Mandanten)
   - d [Verzeichnis]    Verzeichnis mit Holdings-Dateien (Format: FOLIO-JSON). Standardwert: $directory
   - f [Datei]          Die Ladedatei im Format JSON mit einer Liste von Datensätzen.
                        Nicht durch Kommas getrennt, ohne JSON-Kopfelement; also so:
                        { "id" : "0bcf0796-5974-52fa-be23-d329d998d157", ... /* weitere Einträge, die hier irrelevant sind */ }
                        {"id": "c7562874-19a3-58b9-b496-6d0053afd302", ... /* weitere Einträge, die hier irrelevant sind */ }
                        ... (weitere Datensätze [nur die id wird hier benötigt])
                        Standardwert: $useFile
   - h                  Hilfe (dieser Text)
   - l [Datei]      login.json Datei mit Inhalt { "tenant" : "...", "username" : "...", "password" : "..." },
                    Standard $login_datei
   - o [OKAPI_URL]  OKAPI_URL, Default: $OKAPI
   - s              silent off (nicht still), Standard: $silent_off
   - t [TENANT]     TENANT, Default: $TENANT
   - v              verbose (gesprächig), Standard: $verbose
EOF
  exit 0
  }

# Default-Werte
deleteAll=0
useDirectory=1
directory=$HOME/data-migration/migration_repo_template/iterations/test_iteration/results
useFile=0
file=folio_holdings_transform_mfhd.json
verbose=0
silent_off=0
OKAPI=http://localhost:9130
TENANT=diku
login_datei=login.json

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
echo "Lösche FOLIO Inventory Holdings"
echo "in Datei $file"
echo "im Pfad $directory."
echo "TENANT=$TENANT"
echo "OKAPI=$OKAPI"
echo "login-Datei=$login_datei"
curlopts=""
if [ $silent_off != 1 ]; then
  curlopts="$curlopts -s"
fi
if [ $verbose == 1 ]; then
  curlopts="$curlopts -v"
fi
if [ $deleteAll == 1 ]; then
  TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json" -H "Accept: application/json" -d @$login_datei $OKAPI/authn/login | grep -i "^x-okapi-token: " )
  curl $curlopts -S -X DELETE -H "$TOKEN" -H "X-Okapi-Tenant: $TENANT" -H "Content-type: text/plain; charset=utf-8" $OKAPI/holdings-storage/holdings
  echo
elif [ $useFile == 1 ]; then
  actDir=$PWD
  if [ $useDirectory == 1 ]; then
    cd $directory
  fi
  if [ ! -f $file ]; then
    echo "ERROR: ($file) ist keine reguläre Datei!"
    exit 0
  fi
  while IFS= read -r line; do
    unset id
    id=`echo $line | jq ".id"`
    id=$(stripOffQuotes $id)
    echo "Deleting ID: $id ..."
    cd $actDir
    ./deleteHolding.sh -t $TENANT -l $login_datei -o $OKAPI $curlopts $id
  done < $file
  cd $actDir
elif [ $useDirectory ==1 ]; then
  for holding in $directory/*.json; do
    ./deleteHolding.sh -t $TENANT -l $login_datei -o $OKAPI $curlopts -f $holding
  done
else
  echo "ERROR: Neither a file nor a directory was specified ! Nothing done." 
fi

exit 0
