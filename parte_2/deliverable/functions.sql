-- a. funzione che realizza lo scarico dall’inventario dei prodotti scaduti;
CREATE OR REPLACE FUNCTION effettuaScarico() RETURNS VOID AS
$scarico$
    DECLARE
        prodId INT;
        cur CURSOR FOR
            SELECT id
            FROM prodotti
            WHERE data_scarico <= CURRENT_DATE;
    BEGIN
        OPEN cur;
        FETCH cur INTO prodId;

        -- Itera sui prodotti con data e ora di scadenza prima di adesso
        -- e segnali come scaricati
        WHILE FOUND LOOP
            BEGIN
                UPDATE prodotti SET scaricato = true WHERE prodotti.id = prodId;
                FETCH cur INTO prodId;
            END;
        END LOOP;
        CLOSE cur;
    END;
$scarico$ LANGUAGE plpgsql;

-- b. funzione che corrisponde alla seguente query parametrica: dato un volontario e due date, deter-
-- minare i turni assegnati al volontario nel periodo compreso tra le due date.
CREATE OR REPLACE FUNCTION checkTurni(volId INT, d1 DATE, d2 DATE) RETURNS turni AS
$check_turni$
    DECLARE
        result turni;
    BEGIN
        SELECT t.*
        FROM volontari_turni vt
        JOIN turni t on vt.turno = t.id
        JOIN volontari v on vt.volontario = v.id
        WHERE t.data BETWEEN d1 AND d2 AND v.id = volId
        INTO result;
        RETURN result;
    END;
$check_turni$ LANGUAGE plpgsql;

-- NOTA: per usare checkTurni scrivere la seguente query:
-- SELECT * FROM checkTurni(...)