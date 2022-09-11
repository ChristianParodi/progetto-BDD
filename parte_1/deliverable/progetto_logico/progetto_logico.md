---
geometry: "left=2cm,right=2cm,top=1cm,bottom=2cm"
output: pdf_document
---

# `Schema logico`

![Diagramma ER ristrutturato](../media/social_market_v2_ristrutturato.drawio.png){width=98%}

\newpage

#### `eliminazione delle gerarchie`

- `Servizi`
  
  Abbiamo pensato fosse sensato immagazzinare i dati del figlio nel padre (come attributi opzionali), siccome l'ID del padre e' la chiave anche del figlio, nel caso si fosse deciso di tenere 2 tabelle separate, si sarebbe dovuto fare un join per accedere ai dati del veicolo.
- `Turni`
  
  Siccome sia padre che figlio sono associate ad altre tabelle, e' stato necessario "mantenere" le differenze e quindi abbiamo eliminato la gerarchia in favore di 2 tabelle associate
- `Donazioni`
  
  In questo caso abbiamo optato per una soluzione ibrida, ovvero eliminare il figlio nel caso di `Donazioni -> denaro` (siccome non e' associata a niente) e mantenere 2 tabelle associate per `Donazioni -> prodotti` (visto che e' associata a diverse tabelle).
- `Donatori`
  
  In questo caso per tutti e 3 i figli abbiamo associato una tabella aggiuntiva perche', anche se alcune non sono associate con niente, ci sembra piu' comodo avere memorizzati dati cosi' diversi in tabelle diverse.

#### `modifiche effettuate prima della traduzione`

##### `Turni e servizi`

Ristrutturando abbiamo notato due particolarita' dello schema ER che ci fanno storcere il naso riguardo ai `turni` e i `servizi`, ovvero:

- Non sappiamo a che servizio corrisponde un dato turno (sappiamo solo se e' un turno di trasporti ma non sappiamo con quale veicolo e' effettuato)
- Il veicolo viene (eventualmente) salvato in `servizi`, quindi potremmo solamente memorizzare come informazione che il servizio trasporti
  viene eseguito sempre con lo stesso veicolo.

Per risolvere questi problemi, e' bastato associare `turni` e `servizio` (`turno` 'e' di' `servizio`), cosi' facendo viene fuori una relazione (1, n) (dal lato di turno), avendo cosi' come chiave eseterna in turni l'ID del servizio che si sta svolgendo. Viene anche spostato il vicolo nel turno, in modo che sia collegato al singolo turno e che possano quindi essere memorizzati veicoli diversi in turni diversi.

##### `Fasce orarie di disponibilita' dei volontari`

Inizialmente abbiamo pensato di semplicemente scrivere le fasce orarie per ogni volontario come stringa, pero' questa soluzione implica che il volontario sia disponibile in una sola fascia oraria ('giovedi dalle 15 alle 17') oppure scrivere una stringa piu' lunga scrivendo le varie disponilita' separate da virgole, con cui pero' sarebbe stato difficile lavorare. Ci sembra ragionevole ristrutturare quindi l'attributo "disponibilita'" in una tabella aggiuntiva "fasce_orarie" con un ID come chiave, cosi' da poter associare piu' fasce orarie ai singoli volontari e da poter controllare piu' facilmente, per esempio, che un volontario non abbia un turno assegnato in un orario in cui non e' disponibile.

##### `familiari e appuntamenti`

Per come lo abbiamo ora, il nostro database ci permette di memorizzare solamente gli appuntamenti a cui ha partecipato un cliente, ma non i suoi familiari. Siccome memorizziamo se un familiare e' autorizzato o meno ad accedere al market, e' ragionevole possa quindi partecipare agli appuntamenti. Quindi aggiungiamo un'ulteriore associazione `Familiari` 'partecipa a' `Appuntamenti`, con cardinalita' (1, n) dal lato di appuntamenti, risultandone una chiave esterna in appuntamenti. Notiamo che questa chiave esterna e' pero' opzionale, mentre invece la chiave esterna "cliente" in appuntamenti la manterremo (per poter memorizzare quale autorizzazione il familiare ha usato).

#### `schema logico`

**Familiari**(\underline{CF}, nome, cognome, data_nascita, autorizzato,
componente_nucleo, fascia_eta, cliente$^{clienti}$)

**Clienti**(\underline{ID}, nome, cognome, data_nascita, ente_autorizzatore, data_autorizzazione, scadenza_autorizzazione, punti_mensili, saldo_punti, *CF*, n_componenti_nucleo, autorizzato)

**Telefoni**(\underline{numero}, cliente$^{clienti}$)

**Email**(\underline{indirizzo}, cliente$^{clienti}$)

**Appuntamenti**(\underline{ID}, data, ora, componente_nucleo, saldo_iniziale, saldo_finale, cliente$^{clienti}$, volontario$^{volontari}$, familiare$^{familiari}_O$)

**Prodotti**(\underline{ID}, scadenza$_o$, scadenza_reale$_o$, codice_prodotto$^{scorte}$, ID_ingresso$^{ingresso\_prodotti}$, data_scarico$^{scarichi}_o$, ora_scarico$^{scarichi}_o$ scaricato)

**Scorte**(\underline{codice\_prodotto}, tipologia, marca, prezzo, quantita')

**Scarichi**(\underline{data, ora}, volontario$^{volontari}_o$)

**Ingresso_prodotti**(\underline{ID}, data, ora)

**Volontari**(\underline{ID}, nome, cognome, data_nascita, telefono, email)

**Fasce_orarie**(\underline{ID}, giorno, ora_inizio, ora_fine)

**Associazioni**(\underline{nome})

**Servizi**(\underline{nome})

**Turni**(\underline{ID}, data, ora_inizio, ora_fine, servizio$^{servizi}$)

**Turno_trasporti**(\underline{ID$^{turni}$}, volontario$^{volontario}$ ,ora, n_colli, veicolo, sede_ritiro)

**Donazioni**(\underline{ID}, tipologia, data, ora, importo$_o$ donatore$^{donatori}$)

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

**volontari_fasce_orarie**(\underline{volontario$^{volontari}$, fascia\_oraria$^{fasce\_orarie}$})

## `Normalizzazione`

Per verificare la qualita' dello schema ER ristrutturato e' bene controllare che rispetti la `forma normale di Boyce Codd` e, nel caso non la rispettasse e non fosse possibile decomporre lo schema in modo da fargliela rispettare, la `terza forma normale` (che invece e' sempre possibile). Cominciamo elencando le dipendenze funzionali

- Familiari
  - $CF \to nome, cognome, data\_nascita$
- Clienti
  - $ID \to nome, cognome, data\_nascita, ente\_autorizzatore$,

    $data\_autorizzazione, punti\_mensili, saldo\_punti, CF, autorizzato, n\_componenti\_nucleo$
  - $CF \to nome, cognome, data\_nascita$
- Appuntamenti
  - $ID \to data, ora, componente\_nucleo, saldo\_iniziale, saldo\_finale$
  - $data, ora \to ID, componente\_nucleo, saldo\_iniziale, saldo\_finale$
- Prodotti
  - $ID \to nome, prezzo, scadenza, scadenza\_reale, scaricato$
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
- Fasce orarie
  - $ID -> giorno, ora\_inizio, ora\_fine$
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
  - $ID^{donatori} \to ...$
  - $CF \to ID^{donatori}$

Si puo' notare che tutte le dipendenze "sinistre" contengono una chiave, di conseguenza lo schema e' normalizzato rispetto a Boyce Codd

\underline{NOTA}: "$ID \to ...$" indica che l'ID implica tutti gli altri attributi della relazione (essendo chiave)