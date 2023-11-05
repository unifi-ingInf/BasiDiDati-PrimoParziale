/*
Lo schema sotto riportato rappresenta i dati di interesse per monitorare le visite effettuate ai
pazienti di uno studio medico. Paziente contiene i dati dei pazienti con relativi recapiti;
Medico contiene i dati relativi ai medici dello studio. I dati relativi alla prenotazione di una
visita sono memorizzati in PrenotazioneVisita. Per ogni visita realmente fatta (il paziente
che ha prenotato potrebbe poi non presentarsi o disdire) viene aggiunta una riga alla tabella
Visita. DettaglioVisita contiene i dati sui controlli effettuati nella visita con una indicazione
sull’esito (normale true/false) di ciascun controllo. Le prescrizioni fatte al termine di una visita
sono memorizzate nella tabella Prescrizione, mentre la tabella Farmaco esplicita il nome di
ciascun farmaco prescrivibile.
Sussiste un vincolo di integrità referenziale tra gli attributi e le relazioni che hanno lo stesso
nome (per esempio paziente in Visita e la chiave primaria di Paziente)

Paziente(cf, nome, cognome, indirizzo, citta, telefono)
Medico(cf, nome, cognome, indirizzo, citta, telefono)
PrenotazioneVisita(data, ora, paziente, medico)
Visita(codice, data, paziente, medico, costo)
DettaglioVisita(visita, controllo, inNorma, descrizione) 
Controllo(codice, nome)
Prescrizione(visita, farmaco, posologia) 
Farmaco(codice, nome)
*/

-- DDL

CREATE TABLE Paziente (
  cf VARCHAR(16) NOT NULL,
  nome VARCHAR(20) NOT NULL,
  cognome VARCHAR(20) NOT NULL,
  indirizzo VARCHAR(50) NOT NULL,
  citta VARCHAR(20) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  PRIMARY KEY (cf)
);

CREATE TABLE Medico (
  cf VARCHAR(16) NOT NULL,
  nome VARCHAR(20) NOT NULL,
  cognome VARCHAR(20) NOT NULL,
  indirizzo VARCHAR(50) NOT NULL,
  citta VARCHAR(20) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  PRIMARY KEY (cf)
);

CREATE TABLE PrenotazioneVisita (
  data DATE NOT NULL,
  ora TIME NOT NULL,
  paziente VARCHAR(16) NOT NULL,
  medico VARCHAR(16) NOT NULL,
  PRIMARY KEY (data, ora, paziente, medico),
  FOREIGN KEY (paziente) REFERENCES Paziente (cf),
  FOREIGN KEY (medico) REFERENCES Medico (cf)
);

CREATE TABLE Visita (
  codice INT NOT NULL,
  data DATE NOT NULL,
  paziente VARCHAR(16) NOT NULL,
  medico VARCHAR(16) NOT NULL,
  costo DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (codice),
  FOREIGN KEY (paziente) REFERENCES Paziente (cf),
  FOREIGN KEY (medico) REFERENCES Medico (cf)
);

CREATE TABLE DettaglioVisita (
  visita INT NOT NULL,
  controllo INT NOT NULL,
  inNorma BOOLEAN NOT NULL,
  descrizione VARCHAR(50) NOT NULL,
  PRIMARY KEY (visita, controllo),
  FOREIGN KEY (visita) REFERENCES Visita (codice),
  FOREIGN KEY (controllo) REFERENCES Controllo (codice)
);

CREATE TABLE Controllo (
  codice INT NOT NULL,
  nome VARCHAR(20) NOT NULL,
  PRIMARY KEY (codice)
);

CREATE TABLE Prescrizione (
  visita INT NOT NULL,
  farmaco INT NOT NULL,
  posologia VARCHAR(50) NOT NULL,
  PRIMARY KEY (visita, farmaco),
  FOREIGN KEY (visita) REFERENCES Visita (codice),
  FOREIGN KEY (farmaco) REFERENCES Farmaco (codice)
);

CREATE TABLE Farmaco (
  codice INT NOT NULL,
  nome VARCHAR(20) NOT NULL,
  PRIMARY KEY (codice)
);

/*
1. Il numero di visite al termine delle quali non e’ stato prescritto il farmaco F018
2. Il numero di visite in cui non e’ stato effettuato il controllo C014
3. Il medico che ha visitato il maggior numero di diversi pazienti
4. Il paziente che è stato visitato dal maggior numero di diversi medici
5. Il numero medio di farmaci prescritti al termine delle visite
6. Il numero medio di controlli fatti in una visita
*/

-- Query 1

SELECT COUNT(DISTINCT visita)
FROM prescrizione
WHERE farmaco <> 'F018'

-- Query 2

SELECT COUNT(DISTINCT visita)
FROM DettaglioVisita
WHERE controllo <> 'C014'

-- Query 3

SELECT v.medico, count(DISTINCT v.paziente) n_pazienti
FROM Visita v
GROUP BY v.medico
HAVING n_pazienti >= ALL (
    SELECT COUNT(v.paziente)
    FROM Visita v
    GROUP BY v.medico 
)

-- Query 4

SELECT v.paziente, count(DISTINCT v.medico) n_pazienti
FROM Visita v
GROUP BY v.paziente
HAVING n_pazienti >= ALL (
    SELECT COUNT(v.medico)
    FROM Visita v
    GROUP BY v.paziente 
)

-- Query 5

WITH farmaci_per_visita AS (
    SELECT p.visita, count(p.farmaco) n_farmaci
    FROM Prescrizione p
    GROUP BY p.visita
)

SELECT AVG(fpv.n_farmaci)
FROM farmaci_per_visita fpv;

-- Query 6

WITH controlli_per_visita AS (
    SELECT dv.visita, count(dv.controllo) n_controlli
    FROM DettaglioVisita dv
    GROUP BY dv.visita
)

SELECT AVG(cpv.n_controlli)
FROM controlli_per_visita cpv;


