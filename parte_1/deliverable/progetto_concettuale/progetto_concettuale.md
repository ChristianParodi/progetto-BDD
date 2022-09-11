---
geometry: "left=2cm,right=2cm,top=1cm,bottom=2cm"
output: pdf_document
---

\underline{NOTA}: Per tutti i codici SQL abbiamo usato Postgre versione 14.5, in quanto la 9.6 specificata a inizio corso non accettava la sintassi dei trigger

per come l'abbiamo studiata.

## `Requisiti ristrutturati`

Questa base di dati dovra' svolgere diverse mansioni anche motlo diverse fra di loro, ovvero:

#### `Organizzare i prodotti in inventario`

in modo da avere quanta piu' automazione possibile, quindi, per esempio, sapere quando un prodotto sta per finire, aggiornare in automatico le quantita' di un dato prodotto quando questo viene acquistato da un cliente oppure rifornito tramite donazione o acquisto del market, effettuare lo scarico dei prodotti molto vicini alla data di scadenza e memorizzare ogni ingresso prodotti nel market. Il market puo' inoltre acquistare dei prodotti in autonomia nel caso in cui, per esempio, un dato prodotto non venga donato.

**Per ogni prodotto**, si memorizzano la scorta a cui appartiene, il prezzo in punti, la data di scadenza (\underline{nel caso di beni deperibili}) e la data di scadenza "reale", ovvero la data (dopo la data di scadenza) in cui un dato prodotto non e' piu' utilizzabile/commestibile.

**Per ogni scorta di prodotti** viene salvata la tiplogia del prodotto (shampoo, tonno, pasta...), la marca (Garnier, Rio Mare, Barilla...) e la relativa quantita' disponibile.

**Per ogni ingresso prodotti** viene salvata la data e l'ora

**Per ogni scarico prodotti** viene salvata la data e l'ora.

\underline{NOTA}: supponiamo che per ogni scarico si definiscano la data e l'ora, ma che il volontario gli venga assegnato in seguito perche', per esempio, lo scarico e' tra un mese.

#### `Gestire i vari appuntamenti con la clientela`

in modo da memorizzare i vari dati di un appuntamento oltre a poter risalire al cliente che vi ha partecipato, al volontario che lo ha supervisioanto a quali prodotti sono stati acquistati. E' inoltre necessario risalire non solo al cliente ma anche al suo nucleo familiare, siccome i suoi componenti possono acquistare i prodotti a nome del cliente stesso (\underline{se autorizzati a spendere i punti}, in genere chi e' sopra i 16 anni d'eta'). Supponiamo che un cliente possa avere piu' contatti (recapiti telefonici e email) e che fornisca lui i recapiti dei familiari, di conseguenza i familiari non dovranno fornire alcun recapito.

**Per ogni appuntamento** si memorizza la data, l'ora, il componente del nucleo familiare che vi prende parte, il saldo iniziale e il saldo finale.

##### `Ricevere le donazioni`

che possono essere in denaro oppure prodotti, forniti da diverse tipolgie di donatori (privati, negozi, associazioni). Nel caso delle donazioni in prodotti, la consegna al market viene effettuata rispettivamente dal privato nel caso appunto di una donazione in prodotti da un privato, e da un volontario se invece la donazione e' fatta da un negozio o associazione. In ogni caso, ogni donazione viene salvata e collegata al suo donatore e nel caso di una donazione in denaro verra' salvato l'importo, mentre per la donazione in prodotti verra' aggiornato l'inventario e verra' salvato l'ingresso prodotti.

**Per ogni donazione** vengono memorizzate la data, l'ora, e, nel caso di una donazione in denaro, l'importo,

**Per ogni donatore** vengono memorizzati i recapiti (numero di telefono e email), univoci per ogni donatore. Nel caso di un donatore privato si salvano inoltre il nome, il cognome, la data di nascita e il codice fiscale. Per i negozi si salva la ragione sociale e la partita IVA e, infine, per le associazioni il nome e il codice fiscale.

#### `Organizzare il lavoro dei volontari`

memorizzando per quali servizi un dato volontario e' disponibile (e in quali giorni/ore) e organizzando i turni anche in base a queste informazioni.

**Per ogni volontario** si salva il nome, il cognome, la data di nascita, le (eventuali) associazioni a cui e' collegato e i recapiti (univoci, email e numero di telefono).

**Per ogni turno** si salva la data, l'ora di inizio e l'ora di fine. Nel caso di un turno di trasporto merci, si salva anche l'ora del trasporto, il numero di colli da trasportare e la sede del ritiro.

**Per ogni servizio** vengono salvati il nome (es. ritiro merci) e, nel caso di un trasporto merci, il tipo di veicolo utilizzato.

## `Progetto concettuale`

![Diagramma ER](../media/social_market_v2.drawio.png)

\newpage

## `Dizionario entita'`

- `Clienti`

  - **ID**: `int`
    - Numero identificativo (unico per ogni cliente)
  - nome: `string`
  - cognome: `string`
  - data di nascita: `date`
  - codice fiscale: `string`
  - telefono: `string`
    - Numero/i di telefono associati al cliente
  - email: `string`
    - Indirizzo/i email associati al cliente
  - ente_autorizzatore: `string`
    - L'ente che ha concesso l'autorizzazione al cliente
  - data_autorizzazione: `date`
    - data di conseguimento dell'autorizzazione
  - scadenza_autorizzazione: `date`
    - di default dopo 6 mesi dalla data di autorizzazione
  - punti_mensili: `int`
    - saldo mensile che ogni cliente puo' spendere
  - saldo_punti: `int`
    - saldo punti attuale
  - n_componenti_nucleo: `int`
    - il numero dei componenti del nucleo familiare
  - autorizzato: `bool`
    - se il cliente e' autorizzato a spendere i punti oppure no

- `Familiari`

  - **CF**: `string`
    - codice fiscale
  - nome: `string`
  - cognome: `string`
  - data_nascita: `date`
  - componente_nucleo: `string`
    - quale componente del nucleo familiare e' (padre, madre, figlio...)
  - autorizzato: `bool`
    - se e' autorizzato a spendere i punti oppure no
  - fascia eta': `string`
    - fascia d'eta' corrispondente ('0 - 5 anni', '6 - 10 anni'...)

- `Volontari`

  - **ID**: `int`
    - Numero identificativo del volontario (unico per ogni volontario)
  - nome: `string`
  - cognome: `string`
  - data_nascita: `date`
  - telefono: `string`
    - unico per ogni volontario
  - email: `string`
    - unico per ogni volontario
  - disponibilita': `string`
    - fascia oraria e giorni in cui e' disponibile per i servizi (es. il giovedi' dalle 3 alle 5)
  - associazione: `string`
    - l'eventuale associazione/i a cui il volontario e' collegato

- `Fasce orarie`
  - **ID**: `string`
  - giorno: `string`
  - fascia oraria: `string`

- `Prodotti`

  - **ID**: `int`
    - identificativo del singolo prodotto
  - scadenza: `date`
  - scadenza_reale: `date`
    - data oltre il quale e' necessario effettuare lo scarico del prodotto
  - scaricato: `bool`
    - `true` se il prodotto e' gia' stato scaricato, altrimenti `false`

- `Scarichi`

  - **data**: `date`
  - **ora**: `time`

- `Scorte`
  - **codice_prodotto**: `int`
    - codice identificativo per tutti i prodotti con una data tipologia e marca
  - tipologia: `string`
    - Tipologia generica del prodotto (pasta, tonno...)
  - marca: `string`
    - marca del prodotto (de Cecco, Rio Mare...)
  - prezzo: `float`
    - costo in punti
  - quantita': `int`
    - Quantita' disponibile di un dato prodotto in magazzino

- `Ingresso prodotti`
  - **ID**: `int`
  - data: `date`
  - ora: `time`
  - importo speso: `float`
    - Nel caso di prodotti acquistati dal market, si memorizza anche la spesa sostenuta

- `Servizi`
  - **ID**: `int`
  - nome: `string`
    - nome del servizio (es. riordino prodotti)

- `Servizio -> trasporti`
  - veicolo: `string`
    - tipologia del veicolo usato nel caso di un servizio di trasporti

- `Turni`
  - **ID**: `int`
  - data: `date`
  - ora_inizio: `time`
  - ora_fine: `time`
  
- `Turni -> trasporto`
  - ora: `time`
  - n_colli: `int`
    - Numero di cestelli/scatoloni da ritirare
  - sede_ritiro: `string`

- `Donazioni`
  - **ID**: `int`
  - data: `date`
  - ora: `time`
  - tipologia: `string`
    - "denaro" o "prodotti"

- `Donazioni -> denaro`
  - importo: `float`
    - ammontare della donazione

- `Donazioni -> prodotti`

- `Donatori`
  - **ID**: `int`
  - telefono: `string`
  - email: `string`
  - tipologia: `string`
    - "privato", "negozio" o "associazione"

- `Donatori -> privati`
  - nome: `string`
  - cognome: `string`
  - data_nascita: `date`
  - CF: `string`
    - codice fiscale

- `Donatori -> negozi`
  - ragione_sociale: `string`
  - p_iva: `string`

- `Donatori -> associazioni`
  - nome: `string`
  - CF: `string`
    - codice fiscale

## `vincoli d'integrita'`

- `Familiari`
  - l'autorizzazione a spendere i punti si ha se il componente
    del nucelo familiare ha piu' di 16 anni di eta' (ma puo' comunque essere revocata per qualsiasi motivo)
  - 'CF' e' univoco

- `Clienti`
  - 'ID' e' univoco
  - Ogni cliente puo' avere uno o piu' numeri di telefono
  - Ogni cliente puo' avere uno o piu' indirizzi email
  - il codice fiscale e' univoco
  - la scadenza dell'autorizzazione e' di default 6 mesi dopo la data dell'autorizzazione
  - la data dell'autorizzazione deve essere superiore o uguale alla data dell'inserimento
  - la data di scadenza deve essere maggiore della data di autorizzazione
  - i punti mensili devono essere compresi tra 30 e 60
  - il saldo punti non puo' essere minore di 0
  - il cliente deve essere maggiorenne
  - numero componenti familiari deve essere maggiore di 0

- `Appuntamenti`
  - 'ID e' univoco'
  - data e ora sono univoche insieme
  - 'saldo_iniziale' deve essere maggiore di 0
  - 'saldo_finale' deve essere minore di 'saldo_iniziale'

- `Prodotti`
  - 'ID' e' univoco
  - 'scadenza_reale' deve essere maggiore di 'scadenza'

- `Scorte`
  - 'codice_prodotto' e' univoco
  - quantita' deve essere maggiore o uguale di 0
  - 'prezzo' deve essere maggiore di 0
  - tiplogia e marca devono essere univoci insieme

- `Volontari`
  - 'ID' e' univoco
  - telefono deve essere univoco
  - email deve essere univoca

- `Fasce orarie`
  - 'ID' e' univoco
  - giorno e fascia oraria sono unique insieme

- `Turni`
  - 'ID' e' univoco

- `Turni -> trasporti`
  - 'n_colli' deve essere maggiore di 0

- `Servizi`
  - il nome del servizio e' univoco

- `Servizi -> trasporti`
  
- `Ingresso prodotti`
  - 'ID' e' univoco
  - data e ora devono essere univoche insieme

- `Acquisto`
  - 'importo_speso' deve essere maggiore di 0

- `Donazioni`
  - 'ID' e' univoco
  - data e ora devono essere univoche insieme
  - tipologia deve essere "denaro" oppure "prodotti"

- `Donazioni -> denaro`
  - 'importo' deve essere maggiore di 0

- `Donazioni -> prodotti`
  - se il consegnatario e' un privato non puo' essere un volontario e viceversa

- `Donatori`
  - 'ID' e' univoco
  - telefono deve essere univoco
  - email deve essere univoca
  - tipologia deve essere "privato", "negozio" o "associazione"

- `Donatori -> privati`
  - 'CF' deve essere univoco

- `Donatori -> negozi`
  - 'p_iva' deve essere univoca

- `Donatori -> associazioni`
  - 'CF' deve essere univoco

### `gerarchie di generalizzazione`

| padre       | figlio/i                            | tipo               |
| ----------- | ----------------------------------- | ------------------ |
| 'Servizi'   | 'Servizio trasporti'                | parziale/esclusivo |
| 'Turni'     | 'Turno trasporti'                   | parziale/esclusivo |
| 'Donazioni' | 'denaro', 'prodotti'                | totale/esclusivo   |
| 'Donatori'  | 'privati', 'negozi', 'associazioni' | totale/esclusivo   |