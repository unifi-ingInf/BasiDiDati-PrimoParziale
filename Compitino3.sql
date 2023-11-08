/*
Lo schema di base dati sotto riportato, è usato per gestire le
informazioni sui libri presenti in una biblioteca.
Esiste un vincolo di integrità referenziale tra gli attributi e le relazioni
che hanno lo stesso nome (per esempio, l’attributo libro in AutoriLibri
e la relazione Libro)

Scrittore(cf, nome, cognome) 
Libro(isbn, titolo, editore)
AutoriLibri(libro, scrittore) 
Editore(codice, nome)
*/

-- DDL
CREATE TABLE Scrittore(
    cf TEXT PRIMARY KEY,
    nome TEXT,
    cognome TEXT
);

CREATE TABLE Editore(
    codice TEXT PRIMARY KEY,
    nome TEXT
);

CREATE TABLE Libro(
    isbn TEXT PRIMARY KEY,
    titolo TEXT,
    editore TEXT,
    FOREIGN KEY (editore) REFERENCES Editore(codice)
);

CREATE TABLE AutoriLibri(
    libro TEXT,
    scrittore TEXT,
    PRIMARY KEY (libro, scrittore),
    FOREIGN KEY (libro) REFERENCES Libro(isbn),
    FOREIGN KEY (scrittore) REFERENCES Scrittore(cf)
);

/*
1. Il nome di ciascun editore ed il numero di libri che ha edito (per gli
editori che non hanno edito libri deve comparire 0)
2. Codice isbn e titolo del libro con il massimo numero di autori
3. Per ciascuno scrittore che ha scritto almeno un libro, il codice fiscale
ed il numero di editori per cui ha scritto dei libri.
*/

-- Query 1
SELECT e.nome, count(l.isbn) n_libri
FROM editore e 
LEFT OUTER JOIN libro l on e.codice = l.editore
GROUP BY e.codice, e.nome;

-- Query 2
SELECT l.isbn, l.titolo
FROM libro l 
JOIN AutoriLibri al on l.isbn = al.libro
group by l.isbn, l.titolo
having count(al.scrittore) >= ALL(
    select count(scrittore)
    FROM autorilibri
    group by libro
);

-- Query 3
SELECT al.scrittore codicefiscale, count(e.codice) n_editori
FROM AutoriLibri al
JOIN libro l on al.libro = l.isbn
JOIN editore e on l.editore = e.codice
GROUP BY s.cf;
