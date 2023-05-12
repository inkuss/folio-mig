#!/bin/bash
# Autor: Ingolf Kuss (hbz NRW)
# Anlagedatum: 26.11.2021
# Beschreibung: Löscht Folio-Titeldatensätze (Instances) aus FOLIO Inventory Instances
source funktionen.sh

usage() {
  cat <<EOF
  Löscht Folio-Titeldatensätze
  Beispielaufrufe:        ./deleteInstances.sh -t mytenant -l login.mytenant.json -d /usr/folio/data-migration/migration_repo_template/iterations/test_iteration/results -f folio_instances_transform_bibs.json > deleteInstances.log
                          ./deleteInstances.sh -t mytenant -l login.mytenant.json -d ~/folio-mig/sample_input/instances # Löscht alle IDs in allen Dateien in diesem Verzeichnis !!
                          ./deleteInstances.sh -t mytenant -l login.mytenant.json -o http://mytenant/okapi -a  # Löscht alle Titeldatensätze !!!

  Optionen:
   - a                  Löscht alle Titeldatensätze (für diesen Mandanten)
   - d [Verzeichnis]    Verzeichnis mit Titeldaten (Format: FOLIO-JSON). Standardwert: $directory
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
file=folio_instances_transform_bibs.json
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
echo "BEGINN Lösche FOLIO Inventory Instances "`date`
echo "in Datei $file"
echo "im Pfad $directory."
echo "TENANT=$TENANT"
echo "OKAPI=$OKAPI"
echo "login-Datei=$login_datei"
zaehler=0
curlopts=""
if [ $silent_off != 1 ]; then
  curlopts="$curlopts -s"
fi
if [ $verbose == 1 ]; then
  curlopts="$curlopts -v"
fi
if [ $deleteAll == 1 ]; then
  TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json" -H "Accept: application/json" -d @$login_datei $OKAPI/authn/login | grep -i "^x-okapi-token: " )
  curl $curlopts -S -X DELETE -H "$TOKEN" -H "X-Okapi-Tenant: $TENANT" -H "Content-type: text/plain; charset=utf-8" $OKAPI/instance-storage/instances
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
    zaehler=`expr $zaehler + 1`
    unset id
    id=`echo $line | jq ".id"`
    id=$(stripOffQuotes $id)
    echo "Deleting ID: $id ..."
    cd $actDir
    ./deleteInstance.sh -t $TENANT -l $login_datei -o $OKAPI $curlopts $id
  done < $file
  cd $actDir
  echo "Number of instance records that have been deleted: $zaehler"
elif [ $useDirectory ==1 ]; then
  for instance in $directory/*.json; do
    zaehler=`expr $zaehler + 1`
    ./deleteInstance.sh -t $TENANT -l $login_datei -o $OKAPI $curlopts -f $instance
  done
  echo "Number of instance records that have been deleted: $zaehler"
else
  echo "ERROR: Neither a file nor a directory was specified ! Nothing done." 
fi
echo "ENDE Deleting instance records:" `date`

exit 0
