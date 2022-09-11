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
-- utilizzata per prodotti deperibili e quella per i non deperibili nell’ultimo anno;

-- numero di persone autorizzate per l'accesso
CREATE OR REPLACE VIEW autorizzati_nucleo AS
    SELECT id_cliente, COUNT(*) as n_autorizzati
    FROM nuclei_familiari
    WHERE autorizzato
    GROUP BY id_cliente;

-- numero di componenti familiari appartenenti alla fascia d'eta' piu' bassa
CREATE OR REPLACE VIEW fascia_eta_piu_bassa AS
    SELECT clienti.id as id_cliente, COUNT(fam) as n_appartenenti
    FROM (SELECT * FROM familiari WHERE fascia_eta = '0-5 anni') as fam
    RIGHT JOIN clienti ON fam.cliente = clienti.id
    group by clienti.id
order by clienti.id;

-- numero di prodotti acquistati nell'ultimo anno
CREATE VIEW n_spese_ultimo_anno AS
    SELECT clienti.id as id_cliente, COUNT(p) as n_acquisti
    FROM clienti
    JOIN appuntamenti a on clienti.id = a.cliente
    JOIN appuntamenti_prodotti ap on a.id = ap.appuntamento
    JOIN prodotti p on ap.prodotto = p.id
    WHERE a.data >= CURRENT_DATE - '1 year'::interval
    group by clienti.id;

CREATE OR REPLACE FUNCTION puntiInutilizzati(idCliente INT) RETURNS INT AS
$p_in$
    DECLARE
        tot INT;
        totSpesi INT;
    BEGIN
        -- totale dei punti disponibili
        SELECT saldo_punti * 12 FROM clienti WHERE id = idCliente INTO tot;
        -- totale dei punti spesi durante l'anno
        SELECT SUM(s.prezzo)
        FROM clienti
        JOIN appuntamenti a on clienti.id = a.cliente
        JOIN appuntamenti_prodotti ap on a.id = ap.appuntamento
        JOIN prodotti p on ap.prodotto = p.id
        JOIN scorte s on p.codice_prodotto = s.codice_prodotto
        WHERE clienti.id = idCliente AND a.data >= CURRENT_DATE - '1 year'::interval
        INTO totSpesi;

        RETURN tot - totSpesi;
    END;
$p_in$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION percentualePuntiProdottiDeperibili(idCliente INT) RETURNS FLOAT AS
$perc$
    DECLARE
        tot INT;
        totDepe INT;
    BEGIN
        -- Query per ottenere il prezzo in punti totale di tutti i prodotti acquistati dal cliente nell'ultimo anno
        SELECT SUM(scorte.prezzo)
            FROM clienti
            JOIN appuntamenti ON appuntamenti.cliente = clienti.id
            JOIN appuntamenti_prodotti ON appuntamenti_prodotti.appuntamento = appuntamenti.id
            JOIN prodotti ON appuntamenti_prodotti.prodotto = prodotti.id
            JOIN scorte ON prodotti.codice_prodotto = scorte.codice_prodotto
            WHERE appuntamenti.data >= CURRENT_DATE - '1 year'::interval AND clienti.id = idCliente
            GROUP BY clienti.id
            ORDER BY clienti.id INTO tot;

        -- Query per ottenere il prezzo in punti totale di tutti i prodotti deperibili acquistati dal cliente nell'ultimo anno
        SELECT SUM(scorte.prezzo)
            FROM clienti
            JOIN appuntamenti ON appuntamenti.cliente = clienti.id
            JOIN appuntamenti_prodotti ON appuntamenti_prodotti.appuntamento = appuntamenti.id
            JOIN prodotti ON appuntamenti_prodotti.prodotto = prodotti.id
            JOIN scorte ON prodotti.codice_prodotto = scorte.codice_prodotto
            WHERE prodotti.scadenza IS NOT NULL AND appuntamenti.data >= CURRENT_DATE - '1 year'::interval AND clienti.id = idCliente
            GROUP BY clienti.id
            ORDER BY clienti.id INTO totDepe;

        RETURN tot/totDepe;
    END;
$perc$ LANGUAGE plpgsql;


-- RISULTATO
CREATE VIEW info_nuclei_familiari AS
    SELECT
        clienti.id as cliente, punti_mensili, (punti_mensili - saldo_punti) as punti_residui, n_autorizzati, n_componenti_nucleo,
        n_appartenenti as n_fascia_piu_bassa, n_acquisti, puntiInutilizzati(clienti.id) as punti_inutilizzati, percentualePuntiProdottiDeperibili(clienti.id) as perc_punti_deperibili,
        1 - percentualePuntiProdottiDeperibili(clienti.id) as perc_punti_non_deperibili
        FROM clienti
        JOIN autorizzati_nucleo ON autorizzati_nucleo.id_cliente = clienti.id
        JOIN fascia_eta_piu_bassa fepb on fepb.id_cliente = clienti.id
        JOIN n_spese_ultimo_anno ON n_spese_ultimo_anno.id_cliente = clienti.id
        ORDER BY clienti.id;