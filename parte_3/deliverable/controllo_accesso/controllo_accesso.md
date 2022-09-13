---
geometry: "left=1cm,right=2cm,top=1cm,bottom=2cm"
output: pdf_document
---

# `Controllo d'accesso`

Essendo **Alice** il gestore del market, e' ragionevole possa:

- inserire nuovi prodotti nel DB
- inserire nuovi turni e assegnarli ai vari volontari
- registrare le donazioni ricevute
- inserire gli appuntamenti
- registrare nuovi clienti
- inserire un nuovo scarico prodotti
- registrare nuovi donatori

Mentre per il volontario **Roberto**, i privilegi sono leggermente diversi

- puo' registrare i prodotti in ingresso
- puo' registrare le donazioni ricevute
- effettuare gli scarichi
- dare la propria disponibilita' oraria
- dire per quali servizi e' disponibile

## `Privilegi`

- Alice
  - **SELECT**:
    - tutte le tabelle
  - **UPDATE**:
    - tutte le tabelle
  - **DELETE**:
    - tutte le tabelle
  - **INSERT**:
    - tutte le tabelle
  
- Roberto
  - **SELECT**:
    - tutte le tabelle
  - **UPDATE**:
    - nessuna tabella
  - **DELETE**:
    - nessuna tabella
  - **INSERT**:
    - ingresso_prodotti
    - donazioni
    - prodotti
    - volontari_fasce_orarie
    - volontari_servizi

in SQL, questo si traduce in

```sql
-- Assegnamo tutti i privilegi ad alice, con grant option
-- poiche' essendo il capo ci interessa possa autorizzare
-- anche gli altri volontari
GRANT ALL PRIVILEGES ON 
ALL TABLES TO Alice
WITH GRANT OPTION;

-- Per Roberto, invece, gli diamo la lettura su tutte le tabelle,
-- la scrittura (insert) su tutto cio' che riguarda donazioni
-- ingressi di prodotti. Gli diamo anche i privilegi di scrittura
-- sulle tabelle in cui puo' dare la sua disponibilita' per un determinato
-- servizio o fascia oraria, anche in questo caso senza il privilegio DELETE
-- perche' potrebbe, per esempio, eliminare le disponibila' associate ad un
-- altro volontario
GRANT ALL PRIVILEGES 
ON prodotti
TO Roberto;

GRANT SELECT
ON ALL TABLES
TO Roberto;

GRANT INSERT
ON ingresso_prodotti
TO Roberto;

GRANT INSERT 
ON donazioni
TO Roberto;

GRANT INSERT 
ON prodotti
TO Roberto;

GRANT INSERT
ON volontari_fasce_orarie
TO Roberto;

GRANT INSERT
ON volontari_servizi
TO Roberto;
```