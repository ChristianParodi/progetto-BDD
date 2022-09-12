-- determinare i nuclei familiari che, pur avendo punti assegnati, non hanno effettuato spese nell’ul-
-- timo mese;

SELECT id, cf
FROM clienti
WHERE id NOT IN (
    SELECT c.id
    FROM clienti c
    JOIN appuntamenti a on c.id = a.cliente
    WHERE a.data >= CURRENT_DATE - '1 month'::interval
)

-- determinare le tipologie di prodotti acquistate nell’ultimo anno da tutte le famiglie (cioè ogni fa-
-- miglia ha acquistato almeno un prodotto di tale tipologia nell’ultimo anno);

-- In pratica, per implementare la divisione ci siamo ricavati
-- una tabella intermedia (R) che e' la tabella di ogni acquisto
-- effettuato durante l'anno con cliente e tipologia dell'acquisto,
-- da questa contiamo quante volte compare una data tipologia per ogni cliente (distinto)
-- e se questo numero e' uguale al numero di clienti (distinti) che hanno acquistato qualcosa
-- nell'anno precedente allora posso affermare che quella tipologia e' stata acquistata da tutti.

SELECT tipologia
FROM (
SELECT R.tipologia, COUNT(R.tipologia)
FROM (
    SELECT c.id as id_famiglia, s.tipologia
    FROM scorte s
    NATURAL JOIN prodotti p
    JOIN appuntamenti_prodotti ap on p.id = ap.prodotto
    JOIN appuntamenti a on ap.appuntamento = a.id
    JOIN clienti c on a.cliente = c.id
    WHERE a.data >= CURRENT_DATE - '1 year'::interval) AS R
GROUP BY R.tipologia
HAVING COUNT(DISTINCT R.id_famiglia) = (SELECT COUNT(DISTINCT cliente)
                               FROM clienti
                               JOIN appuntamenti a2 on clienti.id = a2.cliente
                               WHERE a2.data >= CURRENT_DATE - '1 year'::interval)) AS res;

-- determinare i prodotti che vengono scaricati (cioè non riescono ad essere distribuiti alle famiglie)
-- in quantitativo maggiore rispetto al quantitativo medio scaricato per prodotti della loro tipologia
-- (es. di tipologia: pasta/riso, tonno sottolio, olio, caffè, ecc.).

select tipologia, marca, count(prodotti) / 12 as n_scaricati
from scorte natural join prodotti
where data_scarico <= current_date + '2 months'::interval
group by codice_prodotto, tipologia, marca
having count(prodotti) > (
    select count(p) / 12 as n_scaricato
    from scorte s natural join prodotti p
    where data_scarico <= current_date + '2 months'::interval
    and p.codice_prodotto = scorte.codice_prodotto
    group by s.tipologia
);