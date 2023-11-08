/*
Utente(cf, nome, cognome, nascita, indirizzo)
Monopattino(codice, livelloCarica, maxRicariche, dataAcquisto)
Ricarica(monopattino, data)
Noleggio(utente, monopattino, oralnizio, oraTermine, indirizzoTermine, stato)
Stato(codice, descrizione)
*/

/*
Query
1. Separatamente per ciascun utente, il cf dell'utente, 
il numero di noleggi effettuati ed il numero
di volte in cui il noleggio è terminato nello stesso indirizzo 
di residenza dell'utente
2. Il massimo numero di volte per cui un monopattino è 
stato noleggiato, insieme al codice del monopattino
3. Il codice dei monopattini mai noleggiati dopo il 10/10/2021
*/


-- Query 1

WITH noleggi_per_utente(cf, n_noleggi) AS(
    SELECT n.utente, count(n.monopattino)
    FROM Noleggio n 
    GROUP BY n.utente
)

WITH noleggi_stesso_indirizzo(cf, n_noleggi_stesso_indirizzo) AS (
    SELECT u.cf, count(n.monopattino)
    FROM Utente u
    JOIN Noleggio n ON u.cf = n.utente
    WHERE u.indirizzo = n.indirizzoTermine
    GROUP BY n.utente
)

SELECT u.cf, u.nome, u.cognome, npu.n_noleggi, nsi.n_noleggi_stesso_indirizzo
FROM Utente u
NATURAL JOIN noleggi_per_utente npu
NATURAL JOIN noleggi_stesso_indirizzo nsi;


-- Query 2

WITH noleggi_monopattino(monopattino, n_noleggi) AS(
    SELECT n.monopattino, count(n.*)
    FROM Noleggio n 
    GROUP BY n.monopattino
)

SELECT nm.monopattino, nm.n_noleggi
FROM noleggi_monopattino nm
WHERE nm.n_noleggi = (
    SELECT MAX(nm1.n_noleggi)
    FROM noleggi_monopattino nm1
);

-- Query 3

SELECT m.codice
FROM monopattino m
LEFT OUTER JOIN (
    SELECT n1.*
    FROM Noleggio n1
    WHERE n1.oraInizio >= '2021-10-10'
) AS n ON m.codice = n.monopattino
WHERE n.monopattino IS NULL;