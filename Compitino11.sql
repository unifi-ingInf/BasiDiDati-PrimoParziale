/*
Lo schema sotto riportato rappresenta i dati di interesse per la gestione di una officina di auto. La tabella
Utente contiene i dati relativi all'anagrafica degli utenti. La tabella Auto contiene, oltre al numero di
targa che è una chiave primaria per la tabella, la data di prima immatricolazione ed un riferimento al
modello di auto. I dati sui modelli di auto sono memorizzati nella tabella Modello che contiene, oltre
ad un codice identificativo di ciascun modello, i dati del produttore (Mercedes, BMW, Toyota, ...), quelli
del tipo, la cilindrata, l'alimentazione, il peso ed il numero di posti ed il numero di anni di garanzia
standard. La tabella Proprietario abbina la targa di ciascun auto al codice fiscale del suo proprietario.
La tabella Riparazione contiene i riferimenti alle auto portate in riparazione all'officina tra cui un
codice identificativo di ciascuna riparazione, la targa dell'auto, la data di intervento, una descrizione
sommaria della riparazione effettuata ed il costo complessivo della riparazione comprensivo
dell'eventuale sconto fatto al cliente. La tabella DettaglioRiparazione esplicita il dettaglio degli
interventi di riparazione eseguiti abbinando il codice di una riparazione alle righe della tabella
Intervento.
Sussiste un vincolo di integrità referenziale tra gli attributi e le relazioni che hanno lo stesso nome (modello
nella tabella Auto e la chiave primaria della tabella Modello)

Utente(cf, nome, cognome, indirizzo, telefono) 
Auto(targa, data, modello)
Modello(codice, produttore, tipo, cilindrata, 
    alimentazione, peso, posti, garanzia)
Riparazione(codice, data, auto, descrizione, 
    programmata, costo) 
Proprietario(auto, utente)
DettaglioRiparazione(riparazione, intervento) 
Intervento(codice, descrizione, costo_standard)
*/

/*
A1. Codice dei modelli di auto che hanno fatto solo interventi di
manutenzione programmata
A2. Per ciascun modello di auto presente nella tabella Modello, il codice del
modello, il tipo, il numero di riparazioni programmate e quello delle
riparazioni non programmate
A3. Codice fiscale, nome e cognome dell'utente che possiede il maggior
numero di auto di produttori diversi

B1. Codice e descrizione dell'intervento (o degli interventi) che non è mai
stato fatto in una riparazione
B2. Per ciascun modello di auto presente nella tabella Modello, il numero di
riparazioni non programmate effettuate ed il costo complessivo di tali
riparazioni
B3. Codice e descrizione dell'intervento 
più frequente nelle auto del produttore BMW
*/



-- Query A1

SELECT DISTINCT m.codice
FROM Modello m
JOIN Auto a ON m.codice = a.modello
JOIN Riparazione r on a.targa = r.auto
WHERE programmata
AND NOT IN (
    SELECT m1.codice
    FROM Modello m1 
    JOIN Auto a1 ON m1.codice = a1.modello
    JOIN Riparazione r1 on a1.targa = r1.auto
    WHERE NOT programmata
)

-- Query A2 

WITH riparazioni_programmate(codice, n_rip_programmate) AS (
    SELECT r.codice count(r.codice)
    FROM riparazione r
    WHERE programmata
)

WITH riparazioni_non_programmate(codice, n_rip_non_programmate) AS (
    SELECT r.codice, count(r.codice)
    FROM riparazione r
    WHERE NOT programmata
)

SELECT r.codice, rp.n_rip_programmate, rnp.n_rip_non_programmate
FROM riparazione r
JOIN riparazioni_programmate rp ON r.codice = rp.codice
JOIN riparazioni_non_programmate rnp; ON r.codice = rnp.codice

-- Query A3

WITH auto_diverse_per_utente(cf, n_auto_prod_diverso) AS(
    SELECT u.cf, count(DISTINCT m.produttore)
    FROM Utente u
    JOIN Proprietario p ON u.cf = p.utente
    JOIN Auto a ON p.auto = a.targa
    JOIN Modello m ON a.modello = m.codice
    GROUP BY u.cf
)

SELECT u.cf, u.nome, u.cognome
FROM Utente u
JOIN auto_diverse_per_utente adpu ON u.cf = adpu.cf
WHERE adpu.n_auto_prod_diverso = (
    SELECT MAX(adpu1.n_auto_prod_diverso)
    FROM auto_diverse_per_utente adpu1
);


-- Query B3

WITH interventi_bmw(codice, n_interventi) AS(
    SELECT i.codice, count(a.*)
    FROM Auto a 
    JOIN Modello m ON a.modello = m.codice
    JOIN Riparazione r ON a.targa = r.auto
    JOIN DettaglioRiparazione dr ON r.codice = dr.riparazione
    JOIN Intervento i ON dr.intervento = i.codice
    WHERE m.produttore = 'BMW'
    GROUP BY i.codice
)

SELECT i.codice, i.descrizione, ib.n_interventi
FROM Intervento i
JOIN interventi_bmw ib ON i.codice = ib.codice
WHERE ib.n_interventi =(
    SELECT MAX(ib1.n_interventi)
    FROM interventi_bmw ib1
)