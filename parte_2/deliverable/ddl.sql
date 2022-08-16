CREATE SCHEMA IF NOT EXISTS "social_market";
set search_path to "social_market";

CREATE TABLE clienti (
    ID SERIAL PRIMARY KEY,
    nome VARCHAR(30) NOT NULL,
    cognome VARCHAR(30) NOT NULL,
    data_nascita DATE NOT NULL CHECK(data_nascita <= CURRENT_DATE - INTERVAL '18' YEAR),
    ente_autorizzatore VARCHAR(255) NOT NULL,
    data_autorizzazione DATE DEFAULT CURRENT_DATE,
    scadenza_autorizzazione DATE NOT NULL, -- da implementare con un trigger data_autorizzazione + 6 mesi
    punti_mensili INT NOT NULL CHECK(punti_mensili BETWEEN 30 AND 60),
    saldo_punti INT NOT NULL CHECK(saldo_punti >= 0),
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

CREATE TABLE appuntamenti (
    ID SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    ora TIME NOT NULL,
    componente_nucleo VARCHAR(30) NOT NULL,
    saldo_iniziale INT NOT NULL CHECK(saldo_iniziale > 0),
    saldo_finale INT NOT NULL CHECK(saldo_finale < saldo_iniziale),
    cliente INT NOT NULL,
    volontario INT NOT NULL,
    UNIQUE(data, ora)
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
    email VARCHAR(255) UNIQUE NOT NULL,
    disponibilita VARCHAR(255) NOT NULL
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
    ID SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    veicolo VARCHAR(255)
);

CREATE TABLE turni (
    ID SERIAL PRIMARY KEY,
    data DATE NOT NULL,
    ora_inizio TIME NOT NULL,
    ora_fine TIME NOT NULL,
    UNIQUE(data, ora_inizio, ora_fine)
);

CREATE TABLE turni_trasporti (
    ID INT PRIMARY KEY,
    volontario INT NOT NULL,
    ora TIME NOT NULL,
    n_colli INT CHECK(n_colli > 0),
    sede_ritiro VARCHAR(255) NOT NULL,
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
    servizio INT,
    PRIMARY KEY(volontario, servizio),
    FOREIGN KEY (volontario) REFERENCES volontari(ID)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE,
    FOREIGN KEY (servizio) REFERENCES servizi(ID)
                                   ON DELETE CASCADE
                                   ON UPDATE CASCADE
);