---
geometry: "left=2cm,right=2cm,top=1cm,bottom=2cm"
output: pdf_document
---

# `Requisiti ristrutturati`

Questa base di dati dovra' svolgere diverse mansioni anche motlo diverse fra di loro, ovvero:

#### `Organizzare i prodotti in inventario`

in modo da avere quanta piu' automazione possibile, quindi, per esempio, sapere quando un prodotto sta per finire, aggiornare in automatico le quantita' di un dato prodotto quando questo viene acquistato da un cliente oppure rifornito tramite donazione o acquisto del market, effettuare lo scarico dei prodotti molto vicini alla data di scadenza e memorizzare ogni ingresso prodotti nel market. Il market puo' inoltre acquistare dei prodotti in autonomia nel caso in cui, per esempio, un dato prodotto non venga donato.

**Per ogni prodotto**, si memorizzano la marca, il prezzo in punti, la data di scadenza (\underline{nel caso di beni deperibili}) e la data di scadenza "reale", ovvero la data (dopo la data di scadenza) in cui un dato prodotto non e' piu' utilizzabile/commestibile.

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