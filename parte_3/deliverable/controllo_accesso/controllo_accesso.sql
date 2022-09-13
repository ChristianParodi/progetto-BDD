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