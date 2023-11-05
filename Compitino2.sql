/*
Lo schema di base dati sotto riportato, è usato per
gestire le informazioni sulla carriera degli studenti digestire le informazioni sulla carriera degli studenti di
un corso di laurea.
Esiste un vincolo di integrità referenziale tra gli
attributi e le relazioni che hanno lo stesso nome

Studente(matricola, nome, cognome)
Iscrizione(studente, anno)
Esame(codice, nome)
EsamiSostenuti(studente, esame, voto, giorno, mese, anno)
*/

-- DDL
CREATE TABLE Studente(
    matricola TEXT PRIMARY KEY,
    nome TEXT, 
    cognome TEXT
);

CREATE TABLE Iscrizione(
    studente TEXT PRIMARY KEY,
    anno INTEGER CHECK (anno >= 1900 AND anno <= 2024),
    FOREIGN KEY (studente) REFERENCES Studente(matricola)
);

CREATE TABLE Esame(
    codice INTEGER PRIMARY KEY,
    nome TEXT
);

CREATE TABLE EsamiSostenuti(
    studente TEXT,
    esame INTEGER,
    voto INTEGER CHECK (voto >= 18 AND voto <= 30),
    giorno INTEGER CHECK (giorno >= 1 AND giorno <= 31),
    mese INTEGER CHECK (mese >= 1 AND mese <= 12),
    anno INTEGER CHECK (anno >= 1900 AND anno <= 2024),
    PRIMARY KEY (studente, esame),
    FOREIGN KEY (studente) REFERENCES Studente(matricola),
    FOREIGN KEY (esame) REFERENCES Esame(codice)
);

/*
QUERY da svolgere
1. Matricola, nome e cognome dello studente che ha sostenuto il
maggior numero di esami in un anno
2. Codice dell’esame per il quale risulta minima la media dei voti
attribuiti agli studenti
3. Matricola degli studenti che hanno dato più di un esame nello stesso
giorno
*/
