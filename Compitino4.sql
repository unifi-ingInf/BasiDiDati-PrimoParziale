/*
Di seguito è mostrato il modello relazionale di una base dati che organizza le
informazioni di interesse per un’azienda. In particolare, nell’azienda vengono
svolti alcuni progetti cui partecipano gli impiegati dell’azienda stessa. Alcuni
impiegati svolgono il ruolo di supervisore per uno o più progetti.

Vincoli di integrità referenziale:
attributo impiegato nella relazione Partecipazione e la relazione Impiegato
attributo impiegato nella relazione Supervisione e la relazione Impiegato
attributo progetto nella relazione Partecipazione e la relazione Progetto
attributo progetto nella relazione Supervisione e la relazione Progetto

Progetto (codice, nome, budget)
Impiegato (matricola, nome, cognome, stipendio)
Partecipazione (impiegato, progetto)
Supervisione (impiegato, progetto)
*/

-- DDL
CREATE TABLE Progetto(
    codice TEXT PRIMARY KEY,
    nome TEXT,
    budget INTEGER
);

CREATE TABLE Impiegato(
    matricola TEXT PRIMARY KEY,
    nome TEXT,
    cognome TEXT,
    stipendio INTEGER
);

CREATE TABLE Partecipazione(
    impiegato TEXT,
    progetto TEXT,
    PRIMARY KEY (impiegato, progetto),
    FOREIGN KEY (impiegato) REFERENCES Impiegato(matricola),
    FOREIGN KEY (progetto) REFERENCES Progetto(codice)
);

CREATE TABLE Supervisione(
    impiegato TEXT,
    progetto TEXT,
    PRIMARY KEY (impiegato, progetto),
    FOREIGN KEY (impiegato) REFERENCES Impiegato(matricola),
    FOREIGN KEY (progetto) REFERENCES Progetto(codice)
);

/*
La matricola dell’impiegato che partecipa al maggior numero di progetti
Per ogni supervisore, il nome e cognome ed il numero di progetti che supervisiona
Per ogni progetto, lo stipendio medio (avg) degli impiegati che ci partecipano
*/

-- Query 1

WITH progetti_per_impiegato AS(
    SELECT p.impiegato, count(p.progetto) AS num_progetti
    FROM Partecipazione p
    GROUP BY p.impiegato
)

SELECT ppi.impiegato
FROM progetti_per_impiegato ppi
WHERE ppi.num_progetti = (
    SELECT max(ppi1.num_progetti)
    from progetti_per_impiegato ppi1
)

-- oppure

SELECT p.impiegato
FROM Partecipazione p 
GROUP BY p.Impiegato
HAVING count(p.progetto) >= ALL(
    SELECT count(p1.progetto)
    FROM Partecipazione p1
    GROUP BY p1.impiegato
);

-- Query 2

SELECT i.matricola, i.nome, i.cognome, count(s.progetto)
FROM Impiegato i 
JOIN Supervisione s ON i.matricola = s.impiegato
GROUP BY i.matricola, i.nome, i.cognome;

-- Query 3

SELECT p.progetto, avg(i.stipendio)
FROM impiegato i
JOIN Partecipazione p on i.matricola = p.impiegato
GROUP BY p.progetto;

