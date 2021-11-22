#!/bin/bash
OKAPI=https://folio-hbz1.hbz-nrw.de/okapi
if [ -n "$1" ]; then OKAPI=$1; fi
TENANT="diku";
if [ -n "$2" ]; then TENANT=$2; fi
TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json" -H "Accept: application/json" -d @login.json $OKAPI/authn/login | grep -i "^x-okapi-token: " )
curl -s -S -X GET -H "$TOKEN" -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json; charset=utf-8" -H "Accept: application/json" $OKAPI/instance-storage/instance-relationships?limit=1000
