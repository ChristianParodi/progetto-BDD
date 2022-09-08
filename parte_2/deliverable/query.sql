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

select s.tipologia
from appuntamenti a
join appuntamenti_prodotti ap on a.id = ap.appuntamento
join prodotti p on ap.prodotto = p.id
join scorte s on p.codice_prodotto = s.codice_prodotto
where a.data >= CURRENT_DATE - '1 year'::interval
group by s.tipologia;

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