-- Specificare il carico di lavoro identificato da 3 interrogazioni di cui una complessa e una che contenga almeno un join

-- Selezione di tutti i prodotti da scaricare entro un anno da oggi

SELECT *
FROM prodotti
WHERE data_scarico BETWEEN CURRENT_DATE AND CURRENT_DATE + '1 year'::interval;

-- dato il turno con id = 1, selezionare tutti i turni presenti nella stessa data (eccetto il turno stesso)

SELECT t.*
FROM turni t
WHERE t.data = (
    SELECT data
    FROM turni
    WHERE id = 1
) AND id <> 1;

-- Quanti colli il volontario trasportera' nei prossimi 2 mesi

SELECT v.id, SUM(n_colli) as n_colli_trasportati
FROM volontari v
JOIN turni_trasporti tt on v.id = tt.volontario
JOIN turni t ON tt.id = t.id
WHERE t.data <= CURRENT_DATE + '2 months'::interval
GROUP BY v.id

