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

-- Verifica del vincolo che ogni volontario non si assegnato a piu' attivita'
-- contemporaneamente

CREATE OR REPLACE FUNCTION checkTurniVol() RETURNS TRIGGER AS
$check_turni_volontari$
    DECLARE
        volTurni turni;
        cur CURSOR FOR
            SELECT *
            FROM turni
            WHERE id = NEW.turno and data = ANY (
                SELECT data
                FROM turni
                WHERE id = NEW.turno
            );
    BEGIN
        OPEN cur;
        FETCH cur INTO volTurni;

        WHILE FOUND LOOP
            BEGIN
                IF (NEW.ora_inizio, NEW.ora_fine) OVERLAPS (volTurni.ora_inizio, volTurni.ora_fine)
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