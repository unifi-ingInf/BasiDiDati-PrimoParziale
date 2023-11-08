/*
Lo schema di base di dati sotto mostrato è usato per registrare il
gradimento degli abbinamenti vino-pietanze. Gli utenti (i cui dati non sono
memorizzati nello schema) inseriscono una o più valutazioni per gli
abbinamenti: ogni valutazione corrisponde ad una riga della tabella
Wine_food_pairing e memorizza un codice unico per la valutazione, il
codice del vino, quello della pietanza ed il codice di valutazione
dell'abbinamento la cui descrizione estesa è memorizzata nella tabella
Rating e può essere Perfect, Positive, Neutral, Unpleasant.
• Sussiste un vincolo di integrità referenziale tra ogni attributo e relazione
con lo stesso nome (per esempio tra l'attributo color nella tabella Wine e
la chiave primaria della tabella Color)

Wine (code, name, color, year)
Color(code, name)
Grape_variety(code, name)
Wine_grape_variety (wine, grape_variety)
Food (code, name, recipe, food_category)
Food _category(code, name)
Wine_food_pairing (code, wine, food, rating)
Rating(code, description)
*/

-- DDL

CREATE TABLE Wine (
  code VARCHAR(16) NOT NULL,
  name VARCHAR(20) NOT NULL,
  color VARCHAR(20) NOT NULL,
  year INTEGER NOT NULL,
  PRIMARY KEY (code),
  FOREIGN KEY (color) REFERENCES Color(code)
);

CREATE TABLE Color (
  code VARCHAR(16) NOT NULL,
  name VARCHAR(20) NOT NULL,
  PRIMARY KEY (code)
);

CREATE TABLE Grape_variety (
  code VARCHAR(16) NOT NULL,
  name VARCHAR(20) NOT NULL,
  PRIMARY KEY (code)
);

CREATE TABLE Wine_grape_variety (
  wine VARCHAR(16) NOT NULL,
  grape_variety VARCHAR(16) NOT NULL,
  PRIMARY KEY (wine, grape_variety),
  FOREIGN KEY (wine) REFERENCES Wine(code),
  FOREIGN KEY (grape_variety) REFERENCES Grape_variety(code)
);

CREATE TABLE Food (
  code VARCHAR(16) NOT NULL,
  name VARCHAR(20) NOT NULL,
  recipe VARCHAR(20) NOT NULL,
  food_category VARCHAR(16) NOT NULL,
  PRIMARY KEY (code),
  FOREIGN KEY (food_category) REFERENCES Food_category(code)
);

CREATE TABLE Food_category (
  code VARCHAR(16) NOT NULL,
  name VARCHAR(20) NOT NULL,
  PRIMARY KEY (code)
);

CREATE TABLE Wine_food_pairing (
  code VARCHAR(16) NOT NULL,
  wine VARCHAR(16) NOT NULL,
  food VARCHAR(16) NOT NULL,
  rating VARCHAR(16) NOT NULL,
  PRIMARY KEY (code),
  FOREIGN KEY (wine) REFERENCES Wine(code),
  FOREIGN KEY (food) REFERENCES Food(code),
  FOREIGN KEY (rating) REFERENCES Rating(code)
);

CREATE TABLE Rating (
  code VARCHAR(16) NOT NULL,
  description VARCHAR(20) NOT NULL,
  PRIMARY KEY (code)
);

/*
A1. I codici dei vini e delle pietanze che abbinati hanno ricevuto il massimo
numero di valutazioni pari a 'Perfect'
A2. Il numero di vini prodotti usando un solo vitigno (grape_variety)
A3. Per ogni vino, il codice, il nome ed il numero di valutazioni di
abbinamenti che coinvolgono quel vino, mostrando 0 per i vini che non
compaiono negli abbinamenti

B1. I codice della pietanza (food) che è stata abbinata con un solo vino
B2. Il codice del vino che più spesso compare nelle valutazioni degli
abbinamenti (a prescindere dalla pietanza con cui è abbinato)
B3. Per ogni possibile giudizio, il codice, la descrizione ed il numero di
valutazioni di abbinamenti con quel giudizio, mostrando 0 per i giudizi
mai assegnati
*/

-- Query A1

SELECT wfp.wine, wfp.food
FROM Wine_food_pairing wfp 
WHERE wfp.rating = 'Perfect' 
GROUP BY wfp.wine, wfp.food
HAVING COUNT(wfp.code) >= ALL(
    SELECT COUNT(wfp1.code)
    FROM Wine_food_pairing wfp1
    WHERE wfp1.rating = 'Perfect'
    GROUP BY wfp1.wine, wfp1.food
)

-- Query A2

WITH wine_one_grape AS(
    SELECT wgv.wine
    FROM Wine_grape_variety wgv
    GROUP BY wgv.wine
    HAVING COUNT(wgv.grape_variety) = 1
)

SELECT count(*) n_wines_one_grape
FROM wine_one_grape;

-- Query A3

SELECT w.*, COALESCE(COUNT(wfp.code), 0)
FROM Wine 
LEFT OUTER JOIN Wine_food_pairing wfp on w.code = wfp.wine
GROUP BY w.*;

-- Query B1

SELECT wfp.food
FROM Wine_food_pairing wfp
GROUP BY wfp.food
HAVING COUNT(wfp.wine) = 1

-- Query B2

SELECT wfp.wine
FROM Wine_food_pairing wfp
GROUP BY wfp.wine
HAVING COUNT(wfp.wine) >= ALL(
    SELECT COUNT(wfp1.wine)
    FROM Wine_food_pairing wfp1
    GROUP BY wfp1.wine
)

-- Query B3

SELECT r.*, COALESCE(COUNT(wfp.code), 0)
FROM Rating r
LEFT OUTER JOIN Wine_food_pairing wfp on r.code = wfp.rating
GROUP BY r.*;
