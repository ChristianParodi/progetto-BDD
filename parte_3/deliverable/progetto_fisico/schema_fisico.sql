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

-- Lista dei top donatori privati ordinati per importo decrescente

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
