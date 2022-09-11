-- Specificare il carico di lavoro identificato da 3 interrogazioni di cui una complessa e una che contenga almeno un join

-- Selezione di tutti i volontari che lavorano in data 2022-10-01, la data e l'ora del turno e il servizio che svolgono

SELECT v.id AS id_volontario, v.nome, v.cognome, t.data, t.ora_inizio, t.ora_fine
FROM volontari v
JOIN volontari_turni vt ON vt.volontario = v.id
JOIN turni t ON vt.turno = t.id
WHERE t.data = '2022-10-01';

-- dato il turno con id = 1, selezionare tutti i turni presenti nella stessa data (eccetto il turno stesso)

SELECT t.*
FROM turni t
WHERE t.data = (
    SELECT data
    FROM turni
    WHERE id = 1
) AND id <> 1;

-- selezionare tutti i prodotti scaricati tra il 2022-08-01 e il 2022-10-01

SELECT p.id AS id_prodotto, s.tipologia, s.marca, p.data_scarico
FROM prodotti p NATURAL JOIN scorte s
WHERE p.scaricato AND p.data_scarico BETWEEN '2022-08-01' AND '2022-10-01';

