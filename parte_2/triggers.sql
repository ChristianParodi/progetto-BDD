-- Aggiornamento inventario

-- Aggiungi la quantita' quando viene inserita una tupla in prodotti
-- Sottrai la quantita' quando viene inserita una tupla in appuntamenti_prodotti (il prodotto viene comprato)

-- Vincoli d'integrita'

-- prima di assegnare un volontario ad un turno trasporti, controllare se il volontario e' gia' assegnato ad un altro turno in quella
-- fascia oraria oppure se e' disponibile per il servizio. 
-- diminuire la quantita' dei prodotti quando questi vengono scaricari
-- per le fasce d'eta' dei familiari inserire automaticamente la fascia d'eta' corrispondente all'eta'
-- per i clienti, settare automaticamente la scadenza dell'autorizzazione a 6 mesi dalla data di autorizzazione

-- Scarico dei prodotti

-- La nostra idea era di eseguire una data funzione ogni giorno ad un certo orario, che controllasse quali prodotti 
-- sono da scaricare nella data odierna e quindi rimuoverli dal DB (mantenendo consistente l'inventario). Siccome pero'
-- non e' possibile effettuare questa operazione in postgre, l'ideale sarebbe creare una normale funzione e poi farla eseguire ad
-- un job scheduler (che non faremo). Ci limiteremo quindi a creare una funzione che effettua lo scarico dei prodotti dal db 
-- (quindi che cancella materialmente le tuple), spettera' al volontario eseguire poi questa funzione.

CREATE OR REPLACE FUNCTION scarico(data1 DATE DEFAULT CURRENT_DATE, data2 DATE DEFAULT CURRENT_DATE + '1 month'::interval) 
RETURNS void AS
$scarico$
    -- In questo caso e' necessario che data1 sia prima di data2
    IF data1 > data2 THEN
        RAISE EXCEPTION "la prima data deve essere precedente alla seconda";
    END IF;
    -- E' necessario salvare solamente l'ID del prodotto per poterlo eliminare
    DECLARE 
        id_prodotto INT;
        cur CURSOR FOR
            SELECT id
            FROM prodotti
            WHERE data_scarico BETWEEN data1 AND data2;
    BEGIN
        OPEN cur;
        FETCH cur INTO id_prodotto;
        WHILE FOUND LOOP
            BEGIN
                DELETE FROM prodotti WHERE id = id_prodotto;
                FETCH cur INTO id_prodotto;
            END;
        END LOOP;
        CLOSE cur;
    END;
$scarico$ LANGUAGE plpgsql;