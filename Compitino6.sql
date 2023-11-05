/*
Lo schema sotto riportato rappresenta le informazioni di interesse per la
gestione del sistema di prenotazione posti alle rappresentazioni teatrali
Per gli utenti sono di interesse il cf, nome, cognome e recapito telefonico
Uno spettacolo è caratterizzato da un codice ed ha una descrizione.
Ciascuno spettacolo può essere programmato in una o più date. Ogni giorno
è in programmazione al più un solo spettacolo
Per ciascuna serata in programmazione si possono effettuare delle
prenotazioni su posti numerati
I posti sono numerati univocamente e raggruppati in categorie cui
corrispondono diverse fasce di costo
La categoria di appartenenza di ciascun posto è esplicitata nella relazione
CategoriePosti

Utente(cf, nome, cognome, telefono) 
Spettacolo(codice, descrizione)
Programmazione(data, spettacolo) 
CategoriePosti(posto, categoria)
Prenotazione(data, posto, utente)
Categoria(codice, descrizione, costo)
*/

-- DDL 
CREATE TABLE Categoria (
  codice VARCHAR(16) NOT NULL,
  descrizione VARCHAR(20) NOT NULL,
  costo DECIMAL(10,2) NOT NULL,
  PRIMARY KEY(codice)
);

CREATE TABLE Utente (
  cf VARCHAR(16) NOT NULL,
  nome VARCHAR(20) NOT NULL,
  cognome VARCHAR(20) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  PRIMARY KEY(cf)
);

CREATE TABLE Spettacolo (
  codice VARCHAR(16) NOT NULL,
  descrizione VARCHAR(20) NOT NULL,
  PRIMARY KEY(codice)
);

CREATE TABLE Programmazione (
  data DATE NOT NULL,
  spettacolo VARCHAR(16) NOT NULL,
  PRIMARY KEY(data),
  FOREIGN KEY(spettacolo) REFERENCES Spettacolo(codice)
);

CREATE TABLE CategoriePosti (
  posto VARCHAR(16) NOT NULL,
  categoria VARCHAR(16) NOT NULL,
  PRIMARY KEY(posto),
  FOREIGN KEY(categoria) REFERENCES Categoria(codice)
);

CREATE TABLE Prenotazione (
  data DATE NOT NULL,
  posto VARCHAR(16) NOT NULL,
  utente VARCHAR(16) NOT NULL,
  PRIMARY KEY(data, posto),
  FOREIGN KEY(data) REFERENCES Programmazione(data),
  FOREIGN KEY(posto) REFERENCES CategoriePosti(posto),
  FOREIGN KEY(utente) REFERENCES Utente(cf)
);

/*
1. Descrizione dello spettacolo in programmazione il 15-12-2006 e
numero dei posti prenotati
2. I dati di ciascun utente ed il costo totale dei biglietti da
lui prenotati, ordinando i risultati per costo decrescente
3. Per ciascuna categoria, il nome ed il numero medio di
posti prenotati negli spettacoli successivi al 10-1-06
*/

-- QUERY 1

SELECT s.descrizione, count(pt.posto) posti_prenotati
FROM Spettacolo s 
JOIN Programmazione pg ON s.codice = pg.spettacolo
JOIN Prenotazione pt ON pg.data = pt.data 
GROUP BY s.codice, s.descrizione;

-- QUERY 2

SELECT u.*, sum(c.costo) costo_totale
FROM Utente u
JOIN Prenotazione pt on u.cf = pt.utente
JOIN CategoriePosti cp on pt.posto = cp.posto
JOIN Categoria c on cp.categoria = c.codice
GROUP by u.*
ORDER BY sum(c.costo) DESC;

-- QUERY 3

WITH posti_per_spettacolo AS(
    SELECT pg.spettacolo, c.codice, count(pt.posto) numero_posti
    FROM programmazione pg 
    JOIN Prenotazione pt ON pg.data = pt.data
    JOIN CategoriePosti cp ON pt.posto = cp.posto
    JOIN Categoria c ON cp.categoria = c.codice
    WHERE pg.data > '2006-01-10'
    GROUP BY pg.data, pg.spettacolo, c.codice
)

SELECT c.descrizione, AVG(pps.numero_posti) AS media_posti_prenotati
FROM Categoria c
JOIN posti_per_spettacolo pps ON c.codice = pps.codice
GROUP BY c.codice, c.descrizione;
