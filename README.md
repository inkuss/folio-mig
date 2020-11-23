# folio-mig
Migrationsskripte und -werkzeuge für Folio Open Source Library System

# Hereinladen einer kompletten Beispiel Sequenz Titel - Lokaldaten - Exemplare
- mit Titelbeziehungen (Über- und Unterordnungen)
- aus den Beispieldaten (FOLIO-JSON)

./createInstances.sh -h
  Legt Folio-Titeldatensätze an
  Beispielaufruf:        ./createInstances.sh -d ~/folio-mig/sample_input/instances

  Optionen:
   - d [Verzeichnis]    Verzeichnis mit Titeldaten (Format: FOLIO-JSON)
   - h                  Hilfe (dieser Text)

./createInstances.sh -d ~/folio-mig/sample_input/instances
./createInstanceRelationships.sh -d ~/folio-mig/sample_input/instanceRelationships
./createHoldings.sh -d ~/folio-mig/sample_input/holdings
./createItems.sh -d ~/folio-mig/sample_input/items
