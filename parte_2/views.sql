-- Viste utili per le interrogazioni

-- nuclei familiari (sia clienti che non)
CREATE VIEW nuclei_familiari AS
    SELECT clienti.nome, clienti.cognome, clienti.cf, clienti.id AS id_cliente, 'true' AS is_cliente
    FROM clienti
    UNION
    SELECT familiari.nome, familiari.cognome, familiari.cf, familiari.cliente AS id_cliente, 'false' AS is_cliente
    FROM familiari
    ORDER BY id_cliente