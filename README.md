# folio-mig
Scripts and tools to load inventory data (instances, holdings, items, instanceRelationships) in format FOLIO-Json into Folio Inventory. For Folio Open Source Library System.

Example to load a complete sample sequence of connected instances, holdings and items into Folio Inventory.
- with instance relationships (parent and child relations)

## Sample inventory data
The sample inventory data in sample_inventory/ will create the following inventory, when loaded to Folio:

- 1 multipart monograph, hrid 1890 (uuid 7433...)

- 2 serials (volumes), both belonging to hrid 1890 and hrid 211134 (a series which needs to be there, already):
  - hrid 1891 (uuid cbcf...) with 2 holdings:
    - holding 10000001 in location: main library, with 1 item:
      - item hrid 31364
    - holding 10000002 in location: second floor, with 1 item:
      - item hrid 91512

  - hrid 1893 (uuid 503b...) with 1 holding:
    - holding 10000003 in location: main library, with 2 items:
      - item hrid 31366 with copy nr 001 and call number type: shelving control number
      - item hrid 91514 with copy nr 002 and call number type: other

- ( a series hrid 211484 needs to be there already ) 
- 1 single unit, hrid 211492 (uuid d7ac...), belonging to series hrid 211484, with 1 holding:
  - holding 10000004 in location: annex, with 1 item:
    - item hrid 4711
    
# folio-mig
Migrationsskripte und -werkzeuge für Folio Open Source Library System

## Loading a complete sample set with instances, holdings, items and instance relationships
- mit Titelbeziehungen (Über- und Unterordnungen)
- out of the same data in this repo (FOLIO-JSON)

```
# i. Create loadfiles:
./createInstancesLoadfiles.sh -d ~/folio-mig/sample_input/instances
# ii. Load records via loadfiles:
./loadInstances.sh -s -v -d ~/folio-mig/sample_input/instances
./createHoldingsLoadfiles.sh -d ~/folio-mig/sample_input/holdings
./loadHoldings.sh -s -v -d ~/folio-mig/sample_input/holdings
./createItemsLoadfiles.sh -d ~/folio-mig/sample_input/items
./loadItems.sh -s -v -d ~/folio-mig/sample_input/items
./createInstanceRelationships.sh -d ~/folio-mig/sample_input/instanceRelationships
```

## Deleting the complete sample set
- das Löschen ist in umgekehrter Reihenfolge vorzunehmen; so:

```
./deleteItems.sh -d ~/folio-mig/sample_input/items
./deleteHoldings.sh -d ~/folio-mig/sample_input/holdings
./deleteInstanceRelationships.sh -d ~/folio-mig/sample_input/instanceRelationships
./deleteInstances.sh -d ~/folio-mig/sample_input/instances
```
 
