-- WORKLOAD
-- Selezione di tutti i prodotti vicini alla scadenza con quantita' minore di 250

SELECT p.id, s.tipologia, s.marca, p.scadenza_reale, p.data_scarico, s.qta
FROM prodotti p
NATURAL JOIN scorte s
WHERE p.scadenza_reale <= CURRENT_DATE + '1 year'::interval AND s.qta <= 250;

-- Per ogni volontario, il numero totale di colli che trasportera' nei prossimi 2
-- mesi (se ce ne sono)

SELECT v.id, SUM(n_colli) as n_colli_trasportati
FROM volontari v
JOIN turni_trasporti tt on v.id = tt.volontario
JOIN turni t ON tt.id = t.id
WHERE t.data <= CURRENT_DATE + '2 months'::interval
GROUP BY v.id;

-- Lista dei top donatori privati (quelli che hanno donato piu' soldi) 
-- ordinati per importo decrescente

SELECT d.id AS id_donatore, SUM(importo) as tot_donazione
FROM donatori d
JOIN donazioni d2 on d.id = d2.donatore
WHERE importo IS NOT NULL AND d.id IN (SELECT id FROM donatori_privati) AND d2.data <= CURRENT_DATE - '1 year'::interval
GROUP BY d.id
ORDER BY tot_donazione DESC;

-- CREAZIONE SCHEMA FISICO

-- Indice multi-attributo ad albero su data_scadenza, scadenza_reale e data_scarico in prodotti:
CREATE INDEX idx_date_prodotti ON prodotti(data_scadenza, scadenza_reale, data_scarico);
CLUSTER prodotti USING idx_date_prodotti;

-- Indice ad albero su data in turni
CREATE INDEX idx_data ON turni(data);
CLUSTER turni USING idx_data;

-- indice sulla data della donazione e l'importo
CREATE INDEX idx_data ON donazioni(data);
CREATE INDEX idx_importo ON donazioni(importo);
CLUSTER donazioni USING idx_data;

-- TRANSAZIONE
-- dato un volontario (id = 1) otteniamo il numero di turni a cui e' assegnato
-- dopodiche', inseriamo un nuovo turno e lo assegnamo al dato volontario,
-- infine ricalcoliamo il dato
BEGIN
      SERIALIZABLE;

      SELECT v.id AS id_volontario, COUNT(*) AS n_turni
      FROM volontari v
      JOIN volontari_turni vt ON vt.volontario = v.id
      GROUP BY v.id;
 
      -- Assegnamo un nuovo turno al volontario
      INSERT INTO volontari_turni(volontario, turno) VALUES
                  (1, 1000);

      SELECT v.id AS id_volontario, COUNT(*) AS n_turni
      FROM volontari v
      JOIN volontari_turni vt ON vt.volontario = v.id
      GROUP BY v.id;
END;

-- CONTROLLO D'ACCESSO
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