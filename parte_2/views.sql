-- Viste utili per le interrogazioni

-- nuclei familiari (sia clienti che non)
CREATE VIEW nuclei_familiari AS
    SELECT f.nome, f.cognome, f.autorizzato, f.cliente AS id_cliente, 'false' AS is_cliente
    FROM familiari f
    UNION
    SELECT c.nome, c.cognome, c.autorizzato, c.id AS id_cliente, 'true' AS is_cliente
    FROM clienti c
    ORDER BY id_cliente

-- La definizione di una vista che fornisca alcune informazioni riassuntive per ogni nucleo familiare: il numero di 
-- punti mensili a disposizione, i punti residui per il mese corrente, il numero di persone autorizzate per l’accesso 
-- al market, il numero di componenti totali e quelli appartenenti alla fascia d’età più bassa, il numero di 
-- spese effettuate nell’ultimo anno, i punti eventualmente non utilizzati nell’ultimo anno, la percentuale di punti 
-- utilizzata per prodotti deperibili e non deperibili nell’ultimo anno;

-- numero di persone autorizzate per l'accesso
CREATE VIEW autorizzati AS
    SELECT *
    FROM nuclei_familiari
    WHERE autorizzato