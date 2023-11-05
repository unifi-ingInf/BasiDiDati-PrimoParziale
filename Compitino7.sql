/*
Policeman(code, name, surname, address, areaCode)
Fine(code, policeman, car, date, infraction, streetName, areaCode, cost)
Infraction(code, description) 
Car(plateNumber, type, owner)
Owner(code, name, surname, address, areaCode)
AreaCode(code, cityName, provinceName)
*/

-- DDL

CREATE TABLE AreaCode (
    code CHAR(5) NOT NULL,
    cityName VARCHAR(20) NOT NULL,
    provinceName VARCHAR(20) NOT NULL,
    PRIMARY KEY (code)
);

CREATE TABLE Car (
    plateNumber CHAR(7) NOT NULL,
    type VARCHAR(20) NOT NULL,
    owner CHAR(5) NOT NULL,
    PRIMARY KEY (plateNumber),
    FOREIGN KEY (owner) REFERENCES Owner(code)
);

CREATE TABLE Infraction (
    code INTEGER PRIMARY KEY,
    description VARCHAR(20) NOT NULL
);

CREATE TABLE Owner (
    code CHAR(5) NOT NULL,
    name VARCHAR(20) NOT NULL,
    surname VARCHAR(20) NOT NULL,
    address VARCHAR(20) NOT NULL,
    areaCode CHAR(5) NOT NULL,
    PRIMARY KEY (code),
    FOREIGN KEY (areaCode) REFERENCES AreaCode(code)
);

CREATE TABLE Policeman (
    code CHAR(5) NOT NULL,
    name VARCHAR(20) NOT NULL,
    surname VARCHAR(20) NOT NULL,
    address VARCHAR(20) NOT NULL,
    areaCode CHAR(5) NOT NULL,
    PRIMARY KEY (code),
    FOREIGN KEY (areaCode) REFERENCES AreaCode(code)
);

CREATE TABLE FINE (
    code INTEGER SERIAL,
    policeman CHAR(5) NOT NULL,
    car CHAR(7) NOT NULL,
    date DATE NOT NULL,
    infraction INTEGER NOT NULL,
    streetName VARCHAR(20) NOT NULL,
    areaCode CHAR(5) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (code),
    FOREIGN KEY (policeman) REFERENCES Policeman(code),
    FOREIGN KEY (areaCode) REFERENCES AreaCode(code),
    FOREIGN KEY (infraction) REFERENCES Infraction(code),
    FOREIGN KEY (car) REFERENCES Car(plateNumber)
)

/*
1. Codice, nome e cognome di ogni vigile e numero di multe fatte, ordinando i
risultati per valori decrescenti del numero di multe
2. Per ogni CAP, il codice ed il numero medio di multe fatte in un giorno
3. Il CAP dove sono state fatte il maggior numero di multe, insieme a tale
numero
4. Per ogni CAP, il numero di multe fatte a residenti nello stesso CAP ed a
residenti fuori ordinando i risultati per CAP crescente
5. Codice della persona a cui sono state fatte più multe, il numero di multe fatte
ed il costo totale di tali multe
6. Per ogni vigile il suo codice ed il numero medio di multe fatte al giorno negli
ultimi 30 giorni (date>”23/10/2010”)
7. Targa della vettura a cui sono state fatte più multe, il numero di multe fatte ed il
costo totale di tali multe
8. Per ogni proprietario il suo codice ed il numero medio di multe ricevute al
giorno negli ultimi 30 giorni (date>”23/10/2010”)
9. Per ogni CAP, il costo totale delle multe fatte a residenti nello stesso CAP ed a
residenti fuori ordinando i risultati per CAP crescente

*/

-- Query 1

SELECT p.code, p.name, p.surname, count(f.code) n_multe
FROM policeman p 
JOIN Fine f on p.code = f.policeman
GROUP BY p.code, p.name, p.surname
ORDER BY n_multe DESC;

-- Query 2

WITH multe_per_cap_day AS(
    SELECT f.areaCode, count(f.code) n_multe
    FROM Fine f
    GROUP BY f.areaCode, f.date
)

SELECT mpcd.areaCode, AVG(mpcd.n_multe) avg_multe_giornaliere
FROM multe_per_cap_day mpcd
GROUP BY mpcd.areaCode;

-- Query 3

SELECT f.areacode cap, count(f.code) max_multe
FROM Fine f
GROUP BY f.areaCode
having count(f.code) >= ALL (
    SELECT count(*)
    FROM Fine f
    GROUP BY f.areaCode 
)





