# folio-mig
Migrationsskripte und -werkzeuge für Folio Open Source Library System

## Hereinladen einer kompletten Beispielsequenz Titel - Lokaldaten - Exemplare
- mit Titelbeziehungen (Über- und Unterordnungen)
- aus den Beispieldaten im Repo (FOLIO-JSON)

```
./createInstances.sh -d ~/folio-mig/sample_input/instances 
./createInstanceRelationships.sh -d ~/folio-mig/sample_input/instanceRelationships 
./createHoldings.sh -d ~/folio-mig/sample_input/holdings 
./createItems.sh -d ~/folio-mig/sample_input/items
```

## Löschen der kompletten Beispielsequenz
- das Löschen ist in umgekehrter Reihenfolge vorzunehmen; so:

```
./deleteItems.sh -d ~/folio-mig/sample_input/items 
./deleteHoldings.sh -d ~/folio-mig/sample_input/holdings 
./deleteInstanceRelationships.sh -d ~/folio-mig/sample_input/instanceRelationships 
./deleteInstances.sh -d ~/folio-mig/sample_input/instances 
```
 
