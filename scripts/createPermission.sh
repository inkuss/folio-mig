#!/bin/bash
# Autor: I. Kuss, hbz
# Aufruf z.B.: ./ks.createInstance.sh InstanceSample.json
# Beispielaufruf: ./ks.createInstance.sh /usr/folio/folio-mig/sample_input/instances/1891.json
enablepermission=$1
userId=$2
OKAPI=https://folio-hbz1.hbz-nrw.de/okapi
if [ -n "$3" ]; then OKAPI=$3; fi
TENANT="diku";
if [ -n "$4" ]; then TENANT=$4; fi
TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: $TENANT" -H "Content-type: application/json" -H "Accept: application/json" -d @login.json $OKAPI/authn/login | grep -i "^x-okapi-token: " )
curl -s -S -X POST -H "Content-type: application/json" -H "X-Okapi-Tenant: diku" -H "$TOKEN" -d \@$enablepermission $OKAPI/perms/users/$userId/permissions
