-- Trigger che mantiene aggiornata la quantita' dei prodotti in inventario
-- aggiungendone uno ogni volta che viene inserita una tupla in prodotti
CREATE OR REPLACE FUNCTION addQta() RETURNS TRIGGER AS
$add_qta$
    BEGIN
       UPDATE scorte SET qta = qta + 1 WHERE codice_prodotto = NEW.codice_prodotto;
       RETURN NULL;
    END;
$add_qta$ LANGUAGE plpgsql;

CREATE TRIGGER add_qta
AFTER INSERT ON prodotti
FOR EACH ROW EXECUTE FUNCTION addQta();

-- ad ogni inserimento in appuntamenti_prodotti, togli la quantita' in scorte
CREATE OR REPLACE FUNCTION subQta() RETURNS TRIGGER AS
$sub_qta$
    DECLARE
            id_scorta INT;
    BEGIN
        SELECT codice_prodotto FROM prodotti WHERE ID = NEW.prodotto INTO id_scorta;
        UPDATE scorte SET qta = qta - 1 WHERE codice_prodotto = id_scorta;
        RETURN NULL;
    END;
$sub_qta$ LANGUAGE plpgsql;

CREATE TRIGGER sub_qta
AFTER INSERT ON appuntamenti_prodotti
FOR EACH ROW EXECUTE FUNCTION subQta();

CREATE OR REPLACE FUNCTION checkTurniVol() RETURNS TRIGGER AS
$check_turni_volontari$
    DECLARE
        volTurni turni;
        newTurno turni;
        -- Tutti i turni che sono nella stessa data del turno che si vuole inserire (escluso)
        cur CURSOR FOR
            SELECT *
            FROM turni
            WHERE data = (
                SELECT data
                FROM turni
                WHERE id = NEW.turno
            ) AND id <> NEW.turno;
    BEGIN
        OPEN cur;
        FETCH cur INTO volTurni;

        -- Il turno che si vuole assegnare al volontario
        SELECT *
        FROM turni
        WHERE id = NEW.turno
        INTO newTurno;

        WHILE FOUND LOOP
            BEGIN
                IF (currentTurno.ora_inizio, currentTurno.ora_fine) OVERLAPS (volTurni.ora_inizio, volTurni.ora_fine)
                THEN
                    RAISE NOTICE 'Errore: il turno da inserire si sovrappone al turno (%, %, %)', volTurni.data, volTurni.ora_inizio, volTurni.ora_fine;
                    RETURN NULL;
                END IF;
               FETCH cur INTO volTurni;
            END;
        END LOOP;
        CLOSE cur;
    END;
$check_turni_volontari$ LANGUAGE plpgsql;

CREATE TRIGGER checkTurniVolontari
BEFORE INSERT ON volontari_turni
FOR EACH ROW EXECUTE FUNCTION checkTurniVol();