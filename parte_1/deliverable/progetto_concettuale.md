---
geometry: "left=2cm,right=2cm,top=1cm,bottom=2cm"
output: pdf_document
---

## `Progetto concettuale`

![Diagramma ER](media/social_market_v2.drawio.png)

![Diagramma ER ristrutturato](media/social_market_v2_ristrutturato.drawio.png)

\newpage

## `Dizionario entita'`

- `Telefoni`
  - **numero**: `string`
  - cliente$^{clienti}$: `int`
    - identificativo del cliente a cui e' collegato il numero di telefono

- `Email`
  - **indirizzo**: `string`
  - cliente$^{clienti}$: `int`
    - identificativo del cliente a cui e' collegato l'indirizzo email
  
- `Clienti`
  - **ID**: `int`
    - Numero identificativo (unico per ogni cliente)
  - nome: `string`
  - cognome: `string`
  - data di nascita: `date`
  - codice fiscale: `string`
  - ente_autorizzatore: `string`
    - L'ente  che ha concesso l'autorizzazione al cliente
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

- `Volontari`
  - **ID**: `int`
    - Numero identificativo del volontario (unico per ogni volontario)
  - nome: `string`
  - cognome: `string`
  - data di nascita: `date`
  - telefono: `string`
    - unico per ogni volontario   
  - email: `string`
    - unico per ogni volontario
  - disponibilita': `string`
    - fascia oraria e giorni in cui e' disponibile per i servizi (es. il giovedi' dalle 3 alle 5)

- `Associazioni`
  - **nome**: `string`
  
- `Prodotti`
  - **ID**: `int`
    - identificativo del singolo prodotto
  - scadenza: `date`
  - scadenza_reale: `date`
    - data oltre il quale e' necessario effettuare lo scarico del prodotto
  - codice_prodotto$^{scorte}$: `int`
    - identificativo della categoria di prodotto
  - ID_ingresso$^{ingresso\_prodotti}$: `int`
    - ingresso prodotti in cui il singolo prodotto e' entrato nel market
  - data_scarico$^{scarichi}$: `date`
  - ora_scarico$^{scarichi}$: `time`

- `Scarichi`
  - **data**: `date`
  - **ora**: `time`
  - volontario$^{volontari}$: `int`

- `Scorte`
  - **codice_prodotto**: `int`
    - codice identificativo per tutti i prodotti con una data tipologia e marca
  - tipologia: `string`
    - Tipologia generica del prodotto (pasta, tonno...)
  - marca: `string`
    - marca del prodotto (de Cecco, Rio Mare...)
  - prezzo: `float`
    - costo in punti
  - quantita: `int`
    - Quantita' disponibile di un dato prodotto in magazzino

- `Ingresso_prodotti`
  - **ID**: `int`
  - data: `date`
  - ora: `time`
  
- `Acquisto`
  - **ID_ingresso**$^{ingresso\_prodotti}$: `int`
  - importo_speso: `float`

- `Servizi`
  - **ID**: `int`
  - nome: `string`
    - nome del servizio (es. riordino prodotti)
  - veicolo: `string`
    - tipologia del veicolo usato nel caso di un servizio di trasporti

- `Turni`
  - **ID**: `int`
  - data: `date`
  - ora_inizio: `time`
  - ora_fine: `time`
  
- `Turni_trasporto`
  - **ID**$^{turni}$: `int`
  - data$^{turni}$: `date`
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
  - donatore$^{donatori}$: `int`

- `Donazioni_denaro`
  - **ID**$^{donazioni}$: `int`
  - importo: `float`

- `Donazioni_prodotti`
  - **ID**$^{donazioni}$: `int`
  - ID_ingresso$^{ingresso\_prodotti}$: `int`
    - identificativo dell'ingresso prodotti che contiene i prodotti donati
  - turno_trasporti$^{turni\_trasporti}$
    - ID del turno durante cui si svolge il ritiro, `NULL` se la donazione e' da un privato 
  - consegnatario_privato$^{donatori\_privato}$: `int`
    - ID del consegnatario privato se la donazione e' da un privato,
      `NULL` altrimenti

- `Donatori`
  - **ID**: `int`
  - telefono: `string`
  - email: `string`
  - tipologia: `string`
    - "privato", "negozio" o "associazione"

- `Donatori_privati`
  - **ID**$^{donatori}$: `int`
  - nome: `string`
  - cognome: `string`
  - data_nascita: `date`
  - CF: `string`
    - codice fiscale

- `Donatori_negozi`
  - **ID**$^{donatori}$: `int`
  - ragione_sociale: `string`
  - p_iva: `string`

- `Donatori_associazioni`
  -  **ID**$^{donatori}$: `int`
  -  nome: `string`
  -  CF: `string`
     -  codice fiscale

### `associazioni (n, n)`

- `appuntamenti_prodotti`
  - **prodotto**$^{prodotti}$: `int`
    - identificativo del prodotto acquistato
  - **appuntamento**$^{appuntamenti}$: `int`
    - appuntamento durante il quale il prodotto e' stato acquistato
  - quantita'

- `volontari_associazioni`
  - **volontario**$^{volontari}$: `int`
  - **associazione**$^{associazioni}$: `string`

- `volontari_turni`
  - **volontario**$^{volontari}$: `int`
  - **turno**$^{turni}$: `int`

- `volontari_servizi`
  - **volontario**$^{volontari}$: `int`
  - **servizio**$^{servizi}$: `string`

## `carico di lavoro`

Per effettuare tutte le operazioni al meglio, e' necessario stimare un carico di lavoro (quali operazioni verranno fatte piu' spesso, il volume dei dati nel tempo...).

Essendo un social market, ci si aspetta che abbia (sfortunatamente) abbastanza clienti ma non nell'ordine delle decine di milioni, per esempio. Sapendo che la popolazione italiana e' di circa $60,262,778$ e che le persone in poverta' assoluta sono circa $5,600,000$ nel 2022 (dati ISTAT), in percentuale siamo sul circa $10,8\%$. Ora, prendendo la popolazione per esempio di Genova nello stesso anno ($568,999$), il $10,8\%$ corrisponde a  circa $61,451.892$, approssimato diventa $61,452$. In ogni caso siamo sulle `decine/centiaia di migliaia (per le citta' piu' popolose) di clienti`. Occorre notare che per ogni cliente in media si avra' una famiglia al seguito, quindi, supponendo che mediamente le famiglie siano formate da $4$ persone, si avra' qualche `centiaia di migliaia` $\cdot$ `4`, che nel caso delle citta' piu' popolose (es. Roma) esubera il milione di circa `200k`. Quindi, nel caso peggiore, si avranno `1.200.000` clienti tra clienti autorizzati e i loro familiari.

Sapendo all'incirca quanti clienti si hanno, ci si potra' piu' o meno orientare per capire di quanti prodotti il market avra' bisogno, sicuramente piu' dei clienti. Quindi si suppone che, per quantita', i prodotti saranno quelli con il maggior volume tra tutti gli altri dati, seguiti dai clienti (e i loro familiari).

Si suppone che le operazioni svolte maggiormente saranno lo stoccaggio dei prodotti in inventario (quindi inserimenti di prodotti e modifiche delle quantita' nelle scorte), quindi bisogna cercare di non sprecare memoria (per esempio con colonne a `null`) e bisogna ottimizzare le operazioni in particolare su questi dati. Ovviamente anche le altre operazioni (es. creazione turni) verranno fatte regolarmente, pero' non avranno mai milioni di righe come per  i clienti o i prodotti in inventario.

## `Schema logico`

**Familiari**(\underline{CF}, nome, cognome, data_nascita, autorizzato,
componente_nucleo, cliente$^{clienti}$)

**Clienti**(\underline{ID}, nome, cognome, data_nascita, ente_autorizzatore, data_autorizzazione, scadenza_autorizzazione, punti_mensili, saldo_punti, *CF*, n_componenti_nucleo, autorizzato)

**Telefoni**(\underline{numero}, cliente$^{clienti}$)

**Email**(\underline{indirizzo}, cliente$^{clienti}$)

**Appuntamenti**(\underline{ID}, data, ora, componente_nucleo, saldo_iniziale, saldo_finale, cliente$^{clienti}$, volontario$^{volontari}$)

**Prodotti**(\underline{ID}, scadenza$_o$, scadenza_reale$_o$, codice_prodotto$^{scorte}$, ID_ingresso$^{ingresso\_prodotti}$, data_scarico$^{scarichi}_o$, ora_scarico$^{scarichi}_o$)

**Scorte**(\underline{codice\_prodotto}, tipologia, marca, prezzo, quantita')

**Scarichi**(\underline{data, ora}, volontario$^{volontari}_o$)

**Ingresso_prodotti**(\underline{ID}, data, ora)

**Acquisto**(\underline{ID\_ingresso$^{ingresso\_prodotti}$}, importo_speso)

**Volontari**(\underline{ID}, nome, cognome, data_nascita, *telefono*, *email*, disponibilita')

**Associazioni**(\underline{nome})

**Servizi**(\underline{ID}, nome, veicolo$_o$)

**Turni**(\underline{ID}, data, ora\_inizio, ora\_fine)

**Turno_trasporti**(\underline{ID$^{turni}$}, volontario$^{volontario}$ ,ora, n_colli, sede_ritiro)

**Donazioni**(\underline{ID}, tipologia, data, ora, donatore$^{donatori}$)

**Donazioni_denaro**(\underline{donazione$^{donazioni}$}, importo)

**Donazioni_prodotti**(\underline{donazione$^{donazioni}$}, consegnatario_privato$^{donatori\_privati}_o$, ID_turno_consegna$^{turni\_trasporti}_o$, ID_ingresso$^{ingresso\_prodotti}$)

**Donatori**(\underline{ID}, *telefono*, *email*, tipologia)

**Donatori_privati**(\underline{ID$^{donatori}$}, nome, cognome, data_nascita, *CF*)

**Donatori_negozi**(\underline{ID$^{donatori}$}, ragione_sociale, *p_iva*)

**Donatori_associazioni**(\underline{ID$^{donatori}$}, nome, *CF*)

#### `associazioni (n,n)`

**appuntamenti_prodotti**(\underline{prodotto$^{prodotti}$, appuntamento$^{appuntamenti}$})

**volontari_associazioni**(\underline{volontario$^{volontari}$, associazione$^{associazioni}$})

**volontari_turni**(\underline{volontario$^{volontari}$, turno$^{turni}$})

**volontari_servizi**(\underline{volontario$^{volontari}$, servizio$^{servizi}$})

## `Normalizzazione`

Per verificare la qualita' dello schema ER ristrutturato e' bene controllare che rispetti la `forma normale di Boyce Codd` e, nel caso non la rispettasse e non fosse possibile decomporre lo schema in modo da fargliela rispettare, la `terza forma normale` (che invece e' sempre possibile). Cominciamo elencando le dipendenze funzionali

- Familiari(<u>CF</u>, nome, cognome, data_nascita, cliente$^{clienti}$)
  - $CF \to nome, cognome, data\_nascita$
- Clienti
  - $ID \to nome, cognome, data\_nascita, ente\_autorizzatore$,

   $data\_autorizzazione, punti\_mensili, saldo\_punti, CF, autorizzato, n\_componenti\_nucleo$
  - $CF \to nome, cognome, data\_nascita$
- Appuntamenti
  - $ID \to data, ora, componente\_nucleo, saldo\_iniziale, saldo\_finale$
  - $data, ora \to ID, componente\_nucleo, saldo\_iniziale, saldo\_finale$
- Prodotti
  - $ID \to nome, prezzo, scadenza, scadenza\_reale$
- Scorte
  - $codice\_prodotto \to tipologia, quantita'$
  - $tipologia, marca \to prezzo$
- Scarichi
  - $data, ora \to volontario^{volontario}$
- Ingresso_prodotti
  - $ID \to data, ora$
- Acquisto
  - $ID\_ingresso^{ingresso\_prodotti} \to importo\_speso$
- Volontari
  - $ID \to nome, cognome, data\_nascita, telefono, email, disponibilita'$
  - $telefono \to ID$
  - $email \to ID$
- Servizi
  - $ID \to nome, veicolo$
- Turni
  - $ID \to data, ora\_inizio, ora\_fine$
- Turno_trasporti
  - $ID^{turni} \to volontario^{volontari}, ora, n\_colli, sede\_ritiro$
- Donazioni
  - $ID \to ...$
  - $data, ora \to ID$
- Donazioni_denaro
  - $donazione^{donazioni} \to importo\_speso$
- Donazioni_prodotti
  - $donazione^{donazioni} \to ...$
  - $ID\_ingresso^{ingresso\_prodotti} \to donazione^{donazioni}$
- Donatori
  - $ID \to ...$
  - $telefono \to ID, email$
  - $email \to ID, telefono$
- Donatori_privati
  - $ID^{donatori} \to ...$
  - $CF \to nome, cognome, data\_nascita$
- Donatori_negozi
  - $ID^{donatori} \to ...$
  - $p\_iva \to ID^{donatori}$
- Donatori_associazioni
  -  $ID^{donatori} \to ...$
  -  $CF \to ID^{donatori}$

Si puo' notare che tutte le dipendenze "sinsitre" contengono una chiave, di conseguenza lo schema e' normalizzato rispetto a Boyce Codd
## `Query`

Tutti i prodotti acquistati durante l'ultimo appuntamento del cliente con ID = 1

```sql
SELECT * 
FROM Prodotti
JOIN Appuntamenti_prodotti
ON Appuntamenti_prodotti.prodotto = prodotti.ID
JOIN Appuntamenti
ON Appuntamenti_prodotti.appuntamento = Appuntamenti.ID
JOIN Clienti
ON Appuntamenti.cliente = Clienti.ID
WHERE Clienti.ID = 1
```




