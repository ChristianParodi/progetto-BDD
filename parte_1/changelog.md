---
geometry: "left=2cm,right=2cm,top=1cm,bottom=2cm"
output: pdf_document
---

# **Giorno 1**

## `Inizio schema concettuale`

- Aggiunta l'entita' `Clienti` e `Persone` per implementare la memorizzazione del nucleo familiare
- Aggiunte le entita' `Volontari`, `Appuntamenti` e `Prodotti` per implementare l'acquisto dei prodotti da parte
  dei clienti (supervisionati dai volontari).
- Aggiunta l'entita' `Scorte` (da ridenominare) collegata a `Prodotti` per implementare una sorta di inventario
- Per tenere traccia della quantita' di prodotti e sapere comunque la scadenza di ogni singolo prodotto. Esempio:

  - **Tabella `Prodotti`**

    | <u>**ID**</u> | nome               | prezzo | scadenza       | scadenza_reale  | codice_prodotto$^{scorte}$ |
    | ------------- | ------------------ | ------ | -------------- | --------------- | -------------------------- |
    | 1             | `'Neutro Roberts'` | 5      | `'2022-10-09'` | `'2022-12-09'`  | 5432                       |
    | 2             | `'Garnier'`        | 4      | `'2023-05-23'` | `'2023-07-23'`  | 5432                       |
    | 3             | `'Rio Mare'`       | 6.29   | `'2026-01-01'` | `'2026-05-01'`  | 6723                       |
    | 4             | `'Nostromo'`       | 3      | `'2026-01-01'` | `'2026-05-01' ` | 6723                       |

  - **Tabella `Scorte`**

    | <u>**codice_prodotto**</u> | tipologia   | quantita' |
    | -------------------------- | ----------- | --------- |
    | 5432                       | `'Shampoo'` | 50        |
    | 6723                       | `'Tonno'`   | 200       |

    <u>**NOTA**</u>: il prezzo prima era nella tabella `Scorte` e nella tabella `Prodotti` mancava il nome, abbiamo fatto queste modifiche perche' reputiamo abbia senso che per esempio tonni diversi abbiano prezzi diversi e che ci siano appunti diversi tonni tra cui scegliere.
- Iniziata l'implementazione delle `donazioni` con i vari `donatori`, ma siamo ancora in dubbio sul come implementare il fatto che la donazione puo' essere fatta sia di prodotti che in denaro. Abbiamo pensato a collegare `Donazioni` con `Prodotti` e aggiungere un attributo `importo` in `Donazioni` che, nel caso di una donazione in prodotti, e' `NULL`. Questo pero' crea dei problemi. Ovvero:
  - Nel caso in cui la maggior parte delle donazioni fosse fatta in prodotti, la colonna `importo` sarebbe quasi sempre `NULL`
  - Nel caso in cui la maggior parte delle donazioni fosse fatta in denaro, in prodotti ci sarebbe la chiave esterna `ID_donazione` quasi sempre `NULL`. 

  Verrebbe in mente di collegare `Donazioni` e `Scorte`, pero' a noi interessa sapere quali singoli prodotti sono stati donati per memorizzarne, per esempio, la data di scadenza.

# `Da finire`

- Implementazione donazioni
- Implementazione Turni
- Ingresso prodotti
- scarico prodotti scaduti

# **Giorno 2**

Abbiamo implementato il resto delle entita'/associazioni, in particolare

- Abbiamo aggiunto l'entita' `Ingresso prodotti` perche' il progetto richiede di memorizzare ogni ingresso prodotti,
  
  Lo abbiamo collegato sia con `Prodotti` che con `Scorte` di modo da avere una tabella `Ingresso prodotti` cosi:

  **Ingresso prodotti**

  Chiave primaria: {data ora}

    | data           | ora          |
    | -------------- | ------------ |
    | `'2022-11-05'` | `'14:00:00'` |

  **Prodotti**
  
    | *ID* | nome        | scadenza       | scadenza_reale | codice_prodotto$^{scorte}$ | data_ingresso$^{ingresso}$ | ora_ingresso$^{ingresso}$ | data_scarico$^{scarico}$ | ora_scarico$^{scarico}$ |
    | ---- | ----------- | -------------- | -------------- | -------------------------- | -------------------------- | ------------------------- | ------------------------ | ----------------------- |
    | 1    | `'Garnier'` | `'2022-09-10'` | `'2022-11-10'` | `5432`                     | `'2022-11-05'`             | `'14:00:00'`              | `'2022-12-08'`           | `'14:00:00'`            |

  Questo ovviamente ha inciso sull'implementazione delle donazioni, infatti abbiamo cambiato la struttura di tutta la parte di DB dedicata ad esse.

- Abbiamo aggiornato le `Donazioni`, inserendo un'entita' `Prodotti donati` che si comporta come un vero e proprio schedario dove, se un prodotto e' stato donato, li' viene associato alla donazione corrispondente.

  | ID_donazione | ID_ingresso |
  | ------------ | ----------- |
  | `1`          | `1`         |
  | `1`          | `2`         |

  Da notare che, associando direttamente `Donazioni` con `Prodotti`, si avrebbe avuto rispettivamente una relazione $(n, 1)$, di conseguenza si avrebbe avuto una colonna `ID_donazione` in `Prodotti` che, nel caso di prodotti acquistati, sarebbe stata `NULL`.

- Abbiamo inoltre associato `Prodotti donati` sia con `Volontari` che con `Donatori privati` perche', nel caso di negozi o supermercati, il market manda un volontario a ritirare i colli, mentre nel caso di un donatore privato i prodotti vengono portati direttamente al market.
- abbiamo implementato lo `scarico` dei prodotti inserendo un'entita' associata sia ai `Prodotti` che ai `Volontari`

# **Giorno 3**

Abbiamo leggermente cambiato lo schema (prodotti donati e' diventata una generalizzazione di donazioni), nel caso in cui per esempio venisse inserita una donazione da un privato succederebbe la cosa seguente:

- verrebbe inserita una donazione in donazioni prodotti:

  | ID  | tipologia    | data           | ora          | ID_donatore | ID_consegnatario_privato |
  | --- | ------------ | -------------- | ------------ | ----------- | ------------------------ |
  | 1   | `'prodotti'` | `'2022-08-06'` | `'14:00:00'` | 1           | 1                        |

- Verrebbe inserito l'ingresso prodotti:

  | ID  | data           | ora          |
  | --- | -------------- | ------------ |
  | 1   | `'2022-08-06'` | `'14:00:00'` |

- Vengono inseriti i prodotti con ID_ingresso `1`

# `Giorno 4`

Oggi abbiamo iniziato lo schema logico e pertanto ci siamo accorti di alcuni dei problemi che la base di dati aveva dopo la ristrutturazione, ovvero

- Avremmo memorizzato una tabella aggiuntiva per il `Servizio dei trasporti` solamente per memorizzare un campo in piu' pertanto abbiamo eliminato l'entita' figlia e inserito l'attributo opzionale 'veicolo' in `Servizi`
- Abbiamo inserito l'attribiuto "marca" in `Scorte`, che cambia concettualmente cio' che la tabella `Scorte` memorizza. Prima si limitava a memorizzare la quantita' totale di, per esempio, ogni shampoo (senza memorizzare la quantita' del singolo 'Garnier'), adesso invece quantita' si riferisce alla singola marca e quindi anche `codice_prodotto` non e' piu' relativo alla singola  tipolgoia ma alla marca. Ovviamente la tabella `Scorte` avra' piu' tuple, pero' adesso la gestione dell'inventario e' decisamente piu' facilitata.