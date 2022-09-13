-- DDL
-- Creazione dello schema e delle tabelle nel DB

CREATE SCHEMA IF NOT EXISTS "social_market";
set search_path to "social_market";

CREATE TABLE clienti (
    ID SERIAL PRIMARY KEY,
    nome VARCHAR(30) NOT NULL,
    cognome VARCHAR(30) NOT NULL,
    data_nascita DATE NOT NULL CHECK(data_nascita <= CURRENT_DATE - INTERVAL '18' YEAR),
    ente_autorizzatore VARCHAR(255) NOT NULL,
    data_autorizzazione DATE DEFAULT CURRENT_DATE,
    scadenza_autorizzazione DATE NOT NULL, 
    punti_mensili INT NOT NULL CHECK(punti_mensili BETWEEN 30 AND 60),
    saldo_punti INT NOT NULL CHECK(saldo_punti BETWEEN 0 AND punti_mensili),
    CF CHAR(16) UNIQUE NOT NULL,
    n_componenti_nucleo INT NOT NULL CHECK(n_componenti_nucleo > 0),
    autorizzato BOOLEAN DEFAULT TRUE
);

CREATE TABLE familiari (
    CF CHAR(16) PRIMARY KEY,
    nome VARCHAR(30) NOT NULL,
    cognome VARCHAR(30) NOT NULL,
    data_nascita DATE NOT NULL CHECK(data_nascita < CURRENT_DATE),
    fascia_eta VARCHAR(255) NOT NULL,
    autorizzato BOOLEAN NOT NULL,
    componente_nucleo VARCHAR(30) NOT NULL,
    cliente int NOT NULL,
    FOREIGN KEY (cliente) REFERENCES clienti(ID)
                    ON DELETE CASCADE
                    ON UPDATE CASCADE
);


CREATE TABLE telefoni (
    numero VARCHAR(20) PRIMARY KEY,
    cliente INT NOT NULL,
    FOREIGN KEY (cliente) REFERENCES clienti(ID)
                    ON DELETE CASCADE
                    ON UPDATE CASCADE
);

CREATE TABLE email (
    indirizzo VARCHAR(255) PRIMARY KEY,
    cliente INT NOT NULL,
    FOREIGN KEY (cliente) REFERENCES clienti(ID)
                    ON DELETE CASCADE
                    ON UPDATE CASCADE
);

CREATE TABLE scorte (
    codice_prodotto SERIAL PRIMARY KEY,
    tipologia VARCHAR(255) NOT NULL,
    marca VARCHAR(255) NOT NULL,
    prezzo FLOAT NOT NULL CHECK(prezzo > 0),
    qta INT NOT NULL CHECK(qta >= 0),
    UNIQUE(tipologia, marca)
);

CREATE TABLE ingresso_prodotti (
    ID SERIAL PRIMARY KEY,
    data DATE DEFAULT CURRENT_DATE,
    ora TIME DEFAULT CURRENT_TIME,
    importo_speso FLOAT CHECK(importo_speso IS NULL OR importo_speso > 0),
    UNIQUE(data, ora)
);

CREATE TABLE volontari (
    ID SERIAL PRIMARY KEY,
    nome VARCHAR(30) NOT NULL,
    cognome VARCHAR(30) NOT NULL,
    data_nascita DATE NOT NULL CHECK(data_nascita < CURRENT_DATE),
    telefono VARCHAR(13) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE fasce_orarie (
    ID SERIAL PRIMARY KEY,
    giorno varchar(40) NOT NULL,
    ora_inizio TIME NOT NULL,
    ora_fine TIME NOT NULL,
    UNIQUE(giorno, ora_inizio, ora_fine)
);

CREATE TABLE appuntamenti (
    ID SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    ora TIME NOT NULL,
    componente_nucleo VARCHAR(30) NOT NULL,
    saldo_iniziale INT NOT NULL CHECK(saldo_iniziale >= 0),
    saldo_finale INT NOT NULL CHECK(saldo_finale < saldo_iniziale),
    cliente INT NOT NULL,
    volontario INT NOT NULL,
    familiare CHAR(16),
    UNIQUE(data, ora),
    FOREIGN KEY (cliente) REFERENCES clienti(ID)
                    ON DELETE CASCADE
                    ON UPDATE CASCADE,
    FOREIGN KEY (volontario) REFERENCES volontari(ID)
                    ON DELETE RESTRICT
                    ON UPDATE CASCADE,
    FOREIGN KEY (familiare) REFERENCES familiari(CF)
);

CREATE TABLE scarichi (
    data DATE,
    ora TIME,
    volontario INT,
    PRIMARY KEY (data, ora),
    FOREIGN KEY (volontario) REFERENCES volontari(ID)
                     ON DELETE NO ACTION
                     ON UPDATE CASCADE
);

CREATE TABLE prodotti (
    ID SERIAL PRIMARY KEY,
    scadenza DATE,
    scadenza_reale DATE CHECK(scadenza_reale >= scadenza),
    codice_prodotto INT NOT NULL,
    ID_ingresso INT NOT NULL,
    data_scarico DATE,
    ora_scarico TIME,
    scaricato BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (codice_prodotto) REFERENCES scorte(codice_prodotto)
                      ON DELETE CASCADE
                      ON UPDATE CASCADE,
    FOREIGN KEY (ID_ingresso) REFERENCES ingresso_prodotti(ID)
                      ON DELETE NO ACTION
                      ON UPDATE CASCADE,
    FOREIGN KEY (data_scarico, ora_scarico) REFERENCES scarichi(data, ora)
                      ON DELETE SET NULL
                      ON UPDATE CASCADE
);


CREATE TABLE associazioni (
    nome VARCHAR(255) PRIMARY KEY
);

CREATE TABLE servizi (
    nome VARCHAR(255) NOT NULL PRIMARY KEY
);

CREATE TABLE turni (
    ID SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    ora_inizio TIME NOT NULL,
    ora_fine TIME NOT NULL,
    servizio VARCHAR(255) NOT NULL,
    UNIQUE(data, ora_inizio, ora_fine),
    FOREIGN KEY (servizio) REFERENCES servizi(nome)
);

CREATE TABLE turni_trasporti (
    ID INT PRIMARY KEY,
    volontario INT NOT NULL,
    ora TIME NOT NULL,
    n_colli INT CHECK(n_colli > 0),
    sede_ritiro VARCHAR(255) NOT NULL,
    veicolo varchar(255) NOT NULL,
    FOREIGN KEY (ID) REFERENCES turni(ID)
                             ON DELETE CASCADE
                             ON UPDATE CASCADE,
    FOREIGN KEY (volontario) REFERENCES volontari(ID)
                             ON DELETE NO ACTION
                             ON UPDATE CASCADE
);

CREATE TABLE donatori (
    ID SERIAL PRIMARY KEY,
    telefono VARCHAR(13) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    tipologia VARCHAR(255) NOT NULL CHECK(tipologia IN ('privato', 'negozio', 'associazione'))
);

CREATE TABLE donatori_privati (
    ID INT PRIMARY KEY,
    nome VARCHAR(30) NOT NULL,
    cognome VARCHAR(30) NOT NULL,
    data_nascita DATE NOT NULL CHECK(data_nascita < CURRENT_DATE),
    CF CHAR(16) UNIQUE NOT NULL,
    FOREIGN KEY (ID) REFERENCES donatori(ID)
                              ON DELETE CASCADE
                              ON UPDATE CASCADE
);

CREATE TABLE donatori_negozi(
    ID INT PRIMARY KEY,
    ragione_sociale VARCHAR(255) NOT NULL,
    p_iva VARCHAR(255) UNIQUE NOT NULL,
    FOREIGN KEY (ID) REFERENCES donatori(ID)
                              ON DELETE CASCADE
                              ON UPDATE CASCADE
);

CREATE TABLE donatori_associazioni(
    ID INT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    CF CHAR(16) UNIQUE NOT NULL,
    FOREIGN KEY (ID) REFERENCES donatori(ID)
                              ON DELETE CASCADE
                              ON UPDATE CASCADE
);

CREATE TABLE donazioni (
    ID SERIAL PRIMARY KEY,
    tipologia VARCHAR(255) NOT NULL CHECK(tipologia IN ('denaro', 'prodotti')),
    data DATE DEFAULT CURRENT_DATE,
    ora TIME DEFAULT CURRENT_TIME,
    importo FLOAT,
    donatore INT NOT NULL,
    UNIQUE(data, ora),
    FOREIGN KEY (donatore) REFERENCES donatori(ID)
                       ON DELETE NO ACTION
                       ON UPDATE CASCADE
);

CREATE TABLE donazioni_prodotti (
    ID INT PRIMARY KEY,
    consegnatario_privato INT,
    ID_turno_consegna INT,
    ID_ingresso INT NOT NULL,
    FOREIGN KEY (ID) REFERENCES donazioni(ID)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    FOREIGN KEY (consegnatario_privato) REFERENCES donatori_privati(ID)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    FOREIGN KEY (ID_turno_consegna) REFERENCES turni_trasporti(ID)
                                ON DELETE SET NULL
                                ON UPDATE CASCADE,
    FOREIGN KEY (ID_ingresso) REFERENCES ingresso_prodotti(ID)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    CHECK((consegnatario_privato IS NULL AND ID_turno_consegna IS NOT NULL)
              OR (consegnatario_privato IS NOT NULL AND ID_turno_consegna IS NULL))
);


-- associazioni (n, n)

CREATE TABLE appuntamenti_prodotti (
    prodotto INT,
    appuntamento INT,
    PRIMARY KEY(prodotto, appuntamento),
    UNIQUE(prodotto),
    FOREIGN KEY (prodotto) REFERENCES prodotti(ID)
                                   ON DELETE NO ACTION
                                   ON UPDATE CASCADE,
    FOREIGN KEY (appuntamento) REFERENCES appuntamenti(ID)
                                   ON DELETE NO ACTION
                                   ON UPDATE CASCADE
);



CREATE TABLE volontari_associazioni (
    volontario INT,
    associazione VARCHAR(255),
    PRIMARY KEY(volontario, associazione),
    FOREIGN KEY (volontario) REFERENCES volontari(ID)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE,
    FOREIGN KEY (associazione) REFERENCES associazioni(nome)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE
);

CREATE TABLE volontari_turni (
    volontario INT,
    turno INT,
    PRIMARY KEY(volontario, turno),
    FOREIGN KEY (volontario) REFERENCES volontari(ID)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE,
    FOREIGN KEY (turno) REFERENCES turni(ID)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE
);

CREATE TABLE volontari_servizi (
    volontario INT,
    servizio VARCHAR(255),
    PRIMARY KEY(volontario, servizio),
    FOREIGN KEY (volontario) REFERENCES volontari(ID)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE,
    FOREIGN KEY (servizio) REFERENCES servizi(nome)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE
);

CREATE TABLE volontari_fasce_orarie (
    volontario INT,
    fascia_oraria INT,
    PRIMARY KEY (volontario, fascia_oraria),
    FOREIGN KEY(volontario) REFERENCES volontari(ID)
                                    ON DELETE CASCADE
                                    ON UPDATE CASCADE,
    FOREIGN KEY (fascia_oraria) REFERENCES fasce_orarie(ID)
                                    ON DELETE CASCADE
                                    ON UPDATE CASCADE
);

-- VISTE

-- nuclei familiari (ovvero l'insieme dei familiari con il rispettivo cliente)
CREATE VIEW nuclei_familiari AS
    SELECT f.nome, f.cognome, f.autorizzato, f.cliente AS id_cliente, 'false' AS is_cliente
    FROM familiari f
    UNION
    SELECT c.nome, c.cognome, c.autorizzato, c.id AS id_cliente, 'true' AS is_cliente
    FROM clienti c
    ORDER BY id_cliente

-- definizione di una vista che fornisca alcune informazioni riassuntive per ogni nucleo familiare: il numero di 
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

-- numero di prodotti acquistati nell'ultimo anno per ogni cliente
CREATE OR REPLACE VIEW n_spese_ultimo_anno AS
    SELECT clienti.id as id_cliente, COUNT(p) as n_acquisti
    FROM clienti
    JOIN appuntamenti a on clienti.id = a.cliente
    JOIN appuntamenti_prodotti ap on a.id = ap.appuntamento
    JOIN prodotti p on ap.prodotto = p.id
    WHERE a.data >= CURRENT_DATE - '1 year'::interval
    group by clienti.id;

-- Dato un cliente, resituisce i punti non utilizzati nell'ultimo anno
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

-- dato un cliente, questa funzione calcola la percentuale dei punti spesi per prodotti deperibili
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


-- vista richiesta
CREATE VIEW info_nuclei_familiari AS
    SELECT
        clienti.id as cliente, 
        punti_mensili, 
        (punti_mensili - saldo_punti) as punti_residui, 
        n_autorizzati, 
        n_componenti_nucleo,
        n_appartenenti as n_fascia_piu_bassa, n_acquisti, 
        puntiInutilizzati(clienti.id) as punti_inutilizzati, 
        percentualePuntiProdottiDeperibili(clienti.id) as perc_punti_deperibili,
        1 - percentualePuntiProdottiDeperibili(clienti.id) as perc_punti_non_deperibili
        FROM clienti
        JOIN autorizzati_nucleo ON autorizzati_nucleo.id_cliente = clienti.id
        JOIN fascia_eta_piu_bassa fepb on fepb.id_cliente = clienti.id
        JOIN n_spese_ultimo_anno ON n_spese_ultimo_anno.id_cliente = clienti.id
        ORDER BY clienti.id;

-- FUNZIONI

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

-- TRIGGER

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

-- controlla che il turno assegnato al dato volontario
-- non si sovrapponga ad un altro turno che gli
-- e' stato gia' assegnato
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
                IF (newTurno.ora_inizio, newTurno.ora_fine) OVERLAPS (volTurni.ora_inizio, volTurni.ora_fine)
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

CREATE TRIGGER check_turni_volontari
BEFORE INSERT ON volontari_turni
FOR EACH ROW EXECUTE FUNCTION checkTurniVol();