/*
Lo schema sotto riportato rappresenta le informazioni di interesse per una società che vende
prodotti ad utenti registrati. I dati relativi agli utenti sono memorizzati nella tabella User
che include un numero di identificazione (uin), nome, cognome ed indirizzo.
I dati sui prodotti sono memorizzati nella tabella Product che include un numero di
identificazione (pin), nome e costo unitario del prodotto.
Gli ordini effettuati dagli utenti sono memorizzati nella tabella Order. Ogni ordine può
includere diversi prodotti e questo richiede che la tabella Order abbia come chiave il
numero di indentificazione dell’ordine (oin) ed il numero di identificazione del prodotto
(product). Ogni riga riporta anche il numero di elementi richiesti per ciascun prodotto.
Lo stato di ciascun ordine è memorizzato nella tabella OrderStatus che include il numero
d’ordine, il numero di identificazione dell’utente che ha effettuato l’ordine, la data di
effettuazione dell’ordine e lo status dell’ordine:
 status=0 significa “Unavailability of some products”
 status=1 significa “All products available”
 status=2 significa “Products sent”
 status=3 significa “Delivery completed”

Il significato di ciascuno stato è descritto nella tabella Status che include il numero di
identificazione di stato (0, 1, 2 and 3) insieme alla sua descrizione.
Quando un attributo ed una tabella hanno lo stesso nome si deve assumere esistere un
vincolo di integrità referenziale tra l’attributo e la chiave primaria della tabella

User(uin, name, surname, address) 
Product(pin, name, cost)
Order(oin, product, number) 
Status(sin, description)
OrderStatus(oin, user, dateOfIssue, status)
*/

-- DDL

CREATE TABLE User (
    uin INT NOT NULL,
    name VARCHAR(20) NOT NULL,
    surname VARCHAR(20) NOT NULL,
    address VARCHAR(20) NOT NULL,
    PRIMARY KEY (uin)
);

CREATE TABLE Product (
    pin INT NOT NULL,
    name VARCHAR(20) NOT NULL,
    cost INT NOT NULL,
    PRIMARY KEY (pin)
);

CREATE TABLE Order (
    oin INT NOT NULL,
    product INT NOT NULL,
    number INT NOT NULL,
    PRIMARY KEY (oin, product),
    FOREIGN KEY (product) REFERENCES Product(pin)
);

CREATE TABLE Status (
    sin INT NOT NULL,
    description VARCHAR(20) NOT NULL,
    PRIMARY KEY (sin)
);

CREATE TABLE OrderStatus (
    oin INT NOT NULL,
    user INT NOT NULL,
    dateOfIssue DATE NOT NULL,
    status INT NOT NULL,
    PRIMARY KEY (oin),
    FOREIGN KEY (user) REFERENCES User(uin),
    FOREIGN KEY (status) REFERENCES Status(sin)
);

/*
Assumendo che la funzione Elapsed(dateOfIssue) restituisca il numero di
giorni trascorsi dalla dateOfIssue, scrivere in SQL le seguenti
interrogazioni:
1. Per ciascun possibile stato degli ordini, la descrizione ed il numero
effettivo di ordini in quello stato
2. Tutti i dati sull’utente che da più tempo sta ancora aspettando la
consegna dell’ordine
3. Il numero medio di pezzi ordinati nei diversi ordini
*/

-- Query 1

SELECT s.sin, s.description, count(os.oin) n_ordini
FROM Status s 
JOIN OrderStatus os ON s.sin = os.status
GROUP BY s.sin, s.description;

-- Query 2

SELECT u.*
FROM User u
JOIN OrderStatus os ON u.uin = os.user
WHERE os.status < 3
AND Elapsed(os.dateOfIssue) >= ALL(
    SELECT Elapsed(os1.dateOfIssue)
    FROM OrderStatus os1
    WHERE os1.status < 3
);

-- Query 3

WITH prodotti_per_ordine AS(
    SELECT o.oin, sum(o.number) somma_pezzi
    FROM ORDER o
    GROUP BY o.oin
);

SELECT avg(ppo.somma_pezzi)
FROM prodotti_per_ordine ppo;