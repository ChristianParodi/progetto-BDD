---
geometry: "left=2cm,right=2cm,top=1cm,bottom=2cm"
output: pdf_document
---

# `Dati da memorizzare`

### **Clienti**

- ID, nome, cognome, data di nascita, codice fiscale, telefono, email, ente autorizzatore, data autorizzazione (scadenza ogni 6 mesi), punti mensili, saldo punti, numero componenti del nucleo familiare con le relative fasce d'eta', chi puo' utilizzare il saldo punti del nucleo familiare (con i relativi dati anagrafici), se autorizzato a spendere i punti oppure no (tipicamente sopra i 16 anni si)

### **Volontari**

  - ID, nome, cognome, data di nascita, telefono, email, tipo di servizio per cui e' disponibile, finestre temporali di disponibilita' (es. giovedì pomeriggio dalle 3 alle 5), 
  nel caso di servizio di trasporto, il tipo di veicolo (furgone, auto, ecc.)
  varie associazioni a cui e' collegato (scout Age-
sci Genova)

### **Inventario prodotti**

  - tipologia, costo in punti, quantita' disponibile, (nel caso di beni deperibili) data di scadenza.
   Per alcuni prodotti si registra fino a quando il prodotto e' ancora commestibile dopo la data di scadenza (es. olio di oliva: 1 anno aggiuntivo, pasta di grano duro 2 mesi, ecc)

### **Donatori**

- **Negozio**
  - ragione sociale, P. IVA, telefono, email

#### **Privato**

  - nome, cognome, data di nascita, telefono, email

### **Donazioni**

  - data di ricezione, importo se in denaro o ingresso merci se in prodotti

### **Ingresso prodotti**

   - tipo (donazione o acquisto), data e ora, chi riceve i prodotti, chi li consegna, (nel caso di prodotti acquistati direttamente dal market) importo speso

### **Appuntamenti**

   - cliente$^{clienti}$, data e ora, componente nucleo (madre, padre, figlio...), $volontario^{volontari}$, 
   Il volontario registra i prodotti acquistati con relativa quantita' (aggiornando l'inventario)
   saranno associati saldo iniziale e finale
   un appuntamento dura 15 minuti e si distanziano l'un l'altro di 5 minuti

### **Turni volontari**

- **Trasporti**

  - data e ora, chi partecipa, sede del ritiro, numero scatoloni

  Su base giornaliera, settimanale o mensile (a seconda della tipologia del prodotto) viene effettuato lo "scarico" dei prodotti non piu' distribuibili perche' molto vicini alla scadenza reale. Questi alimenti vengono regalati oppure gettati. L'unica operazione che viene effettuata e' lo "scarico" per mantenere l'inventario.