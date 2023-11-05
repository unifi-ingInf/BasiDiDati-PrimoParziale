/*
Lo schema sotto riportato rappresenta le informazioni di interesse per una società che vende prodotti ad
utenti registrati. I dati relativi agli utenti sono memorizzati nella tabella User che include un numero di
indentificazione (uin), nome, cognome ed indirizzo. I dati sui prodotti sono memorizzati nella tabella Product
che include un numero di identificazione (pin), nome, categoria e costo unitario del prodotto. Nella tabella
Category sono elencati i codici di ciascuna categoria e le relative descrizioni. Gli ordini effettuati dagli utenti
sono memorizzati nella tabella Order. Ogni ordine può includere diversi prodotti e questo richiede che la
tabella Order abbia come chiave il numero di indentificazione dell’ordine (oin) ed il numero di identificazione
del prodotto (product). Ogni riga riporta anche il numero di elementi richiesti per ciascun prodotto.
Lo stato di ciascun ordine è memorizzato nella tabella OrderStatus che include il numero d’ordine, il numero
di identificazione dell’utente che ha effettuato l’ordine, la data di effettuazione dell’ordine e lo status
dell’ordine:
• status=0 significa “Unavailability of some products”
• status=1 significa “All products available”
• status=2 significa “Products sent”
• status=3 significa “Delivery completed”
Il significato di ciascuno stato è descritto nella tabella Status che include il numero di identificazione di stato
(0, 1, 2 and 3) insieme alla sua descrizione. Quando un attributo ed una tabella hanno lo stesso nome si
deve assumere esistere un vincolo di integrità referenziale tra l’attributo e la chiave primaria della tabella

User(uin, name, surname, address, city)
-- mgrcld15l16d4 claudio magri via giusti, 3 milano
Product(pin, name, category, cost)
-- P0142 Macchina caffè espresso C07 98.00
Category(cin, description)
-- C07 elettrodomestici
Order(oin, product, number)
-- O05102 P0142 1
OrderStatus(oin, user, dateOfIssue, status)
-- O05102 mgrcld15l56d4 11-12-2007 2
Status(sin, description)
-- 2 Products sent
*/

-- DDL 

CREATE TABLE User (
  uin VARCHAR(16) NOT NULL,
  name VARCHAR(20) NOT NULL,
  surname VARCHAR(20) NOT NULL,
  address VARCHAR(50) NOT NULL,
  city VARCHAR(20) NOT NULL,
  PRIMARY KEY (uin)
);

CREATE TABLE Product (
  pin VARCHAR(16) NOT NULL,
  name VARCHAR(20) NOT NULL,
  category VARCHAR(20) NOT NULL,
  cost DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (pin)
);

CREATE TABLE Category (
  cin VARCHAR(16) NOT NULL,
  description VARCHAR(20) NOT NULL,
  PRIMARY KEY (cin)
);

CREATE TABLE Order (
  oin VARCHAR(16) NOT NULL,
  product VARCHAR(16) NOT NULL,
  number INT NOT NULL,
  PRIMARY KEY (oin, product),
  FOREIGN KEY (product) REFERENCES Product (pin)
);

CREATE TABLE OrderStatus (
  oin VARCHAR(16) NOT NULL,
  user VARCHAR(16) NOT NULL,
  dateOfIssue DATE NOT NULL,
  status INT NOT NULL,
  PRIMARY KEY (oin),
  FOREIGN KEY (user) REFERENCES User (uin)
);

CREATE TABLE Status (
  sin INT NOT NULL,
  description VARCHAR(20) NOT NULL,
  PRIMARY KEY (sin)
);

-- INSERT

INSERT INTO User VALUES ('mgrcld15l16d4', 'claudio', 'magri', 'via giusti, 3', 'milano');
INSERT INTO Product VALUES ('P0142', 'Macchina caffè espresso', 'C07', 98.00);
INSERT INTO Category VALUES ('C07', 'elettrodomestici');
INSERT INTO Order VALUES ('O05102', 'P0142', 1);
INSERT INTO OrderStatus VALUES ('O05102', 'mgrcld15l56d4', '2007-12-11', 2);
INSERT INTO Status VALUES (2, 'Products sent');

/*
1. Per ciascuna categoria, il codice, la descrizione ed il costo complessivo dei prodotti venduti (con
status=3)
2. I dati relativi all’utente che ha speso più di tutti (a prescindere dallo stato dell’ordine)
3. Il costo medio di ciascun ordine
*/

-- Query 1

SELECT c.cin, c.description, SUM(p.cost * o.number)
FROM Category c 
JOIN Product p ON c.cin = p.category
JOIN order o ON p.pin = o.product
JOIN OrderStatus os ON o.oin = os.oin
WHERE os.status = 3
GROUP BY c.cin, c.description; 

-- Query 2

select u.*, SUM(p.cost * o.number)
FROM User u 
JOIN OrderStatus os ON u.uin = os.user 
JOIN Order o on os.oin = o.oin
JOIN Product p on o.product = p.pin
GROUP BY u.*
HAVING SUM(p.cost * o.number) >= ALL (
    SELECT SUM(p1.cost * o1.number)
    FROM User u1 
    JOIN OrderStatus os1 ON u1.uin = os1.user 
    JOIN Order o1 on os1.oin = o1.oin
    JOIN Product p1 on o1.product = p1.pin
    GROUP BY u1.uin
)

-- Query 3

WITH costo_per_ordine AS (
    SELECT o.oin, sum(p.cost * o.number) costo_ordine
    FROM Order o 
    JOIN Product p on o.product = p.pin
    GROUP BY o.oin
)

SELECT AVG(costo_ordine)
FROM costo_per_ordine;




