--1. create the data base
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'ItemManagementDB')
    CREATE DATABASE ItemManagementDB;
GO

USE ItemManagementDB;
GO


-- the reference table (Tipurile, Locatiile, Furnizorii)

-- 1. Categorii (Tabela "1" in relatia M:N)
CREATE TABLE Categorii (
    categorie_id INT PRIMARY KEY IDENTITY(1,1),
    nume VARCHAR(100) NOT NULL UNIQUE,
    descriere VARCHAR(255) 
);

-- 2. Furnizori (Tabela "1" in relatia 1:N cu Articole)
CREATE TABLE Furnizori (
    furnizor_id INT PRIMARY KEY IDENTITY(1,1),
    nume VARCHAR(150) NOT NULL UNIQUE,
    contact_email VARCHAR(100)
);

-- 3. Locatii (Tabela "1" in relatia 1:N cu Stoc)
CREATE TABLE Locatii (
    locatie_id INT PRIMARY KEY IDENTITY(1,1),
    nume_locatie VARCHAR(50) NOT NULL UNIQUE, -- Ex: Raft 1, Depozit Sud
    cod_zona CHAR(2)
);

-- 4. TipuriTranzactii
CREATE TABLE TipuriTranzactii (
    tip_id INT PRIMARY KEY IDENTITY(1,1),
    nume_tip VARCHAR(50) NOT NULL UNIQUE -- Ex: 'IN - Aprovizionare', 'OUT - Vanzare'
);

-- 5. Utilizatori (Pentru audit)
CREATE TABLE Utilizatori (
    utilizator_id INT PRIMARY KEY IDENTITY(1,1),
    nume_utilizator VARCHAR(50) NOT NULL UNIQUE,
    rol VARCHAR(50) NOT NULL -- Ex: Admin, Stock operator
);


-- 6. Articole (Include FK catre Furnizori)
CREATE TABLE Articole (
    articol_id INT PRIMARY KEY IDENTITY(1000,1),
    nume_articol VARCHAR(255) NOT NULL,
    cod_sku VARCHAR(50) UNIQUE,
    pret_curent DECIMAL(10, 2) NOT NULL,
    
    furnizor_id INT,
    FOREIGN KEY (furnizor_id) REFERENCES Furnizori(furnizor_id)
);

-- 7. Stoc (Leaga Articole de Locatii pentru a sti unde se afla)
CREATE TABLE Stoc (
    stoc_id INT PRIMARY KEY IDENTITY(1,1),
    articol_id INT NOT NULL,
    locatie_id INT NOT NULL,
    cantitate INT NOT NULL DEFAULT 0,
    
    FOREIGN KEY (articol_id) REFERENCES Articole(articol_id),
    FOREIGN KEY (locatie_id) REFERENCES Locatii(locatie_id),
    -- Un singur articol poate avea stoc intr-o singura locatie la un moment dat
    UNIQUE (articol_id, locatie_id) 
);



-- 8. Tranzactii (Records the in/out)
CREATE TABLE Tranzactii (
    tranzactie_id INT PRIMARY KEY IDENTITY(1,1),
    articol_id INT NOT NULL,
    cantitate_schimbata INT NOT NULL,
    data_tranzactie DATETIME NOT NULL DEFAULT GETDATE(),
    tip_tranzactie_id INT NOT NULL,
    utilizator_id INT, -- Who made the transaction
    
    FOREIGN KEY (articol_id) REFERENCES Articole(articol_id),
    FOREIGN KEY (tip_tranzactie_id) REFERENCES TipuriTranzactii(tip_id),
    FOREIGN KEY (utilizator_id) REFERENCES Utilizatori(utilizator_id)
);

-- 9. ArticoleCategorii (Tabela de legatura M:N)
CREATE TABLE ArticoleCategorii (
    articol_id INT NOT NULL,
    categorie_id INT NOT NULL,
    
    CONSTRAINT pk_ArticoleCategorii PRIMARY KEY (articol_id, categorie_id),
    FOREIGN KEY (articol_id) REFERENCES Articole(articol_id),
    FOREIGN KEY (categorie_id) REFERENCES Categorii(categorie_id)
);

-- 10. IstoricPreturi
CREATE TABLE IstoricPreturi (
    istoric_id INT PRIMARY KEY IDENTITY(1,1),
    articol_id INT NOT NULL,
    pret_vechi DECIMAL(10, 2) NOT NULL,
    pret_nou DECIMAL(10, 2) NOT NULL,
    data_schimbare DATETIME NOT NULL DEFAULT GETDATE(),
    
    FOREIGN KEY (articol_id) REFERENCES Articole(articol_id)
);

-- Insert data for test (DML)

-- Inserare Utilizatori
INSERT INTO Utilizatori (nume_utilizator, rol) VALUES
('stoc_admin', 'Admin'),
('operator1', 'Operator Stoc'),
('vanzatori','Operator Vanzari'),
('audit','Viewer');



-- Inserare Furnizori
INSERT INTO Furnizori (nume, contact_email) VALUES
('GlobalTech Distributie', 'contact@globaltech.com'),
('Furnizorul Local SRL', 'livrari@local.ro'),
('Ambalaje Profi',Null),
('Componente Rapide','contact@gmail.com');

-- Inserare Categorii
INSERT INTO Categorii (nume) VALUES
('Electronice'),
('Componente'),
('Consumabile'),
('Accesorii'),
('Premium');

-- Inserare Locatii
INSERT INTO Locatii (nume_locatie, cod_zona) VALUES
('Raft A1', 'A1'),
('Raft B2', 'B2'),
('Raft C3', 'C3'),
('Raft D4', 'D4'),
('Depozit Principal', 'DP');

-- Inserare Articole
INSERT INTO Articole (nume_articol, cod_sku, pret_curent, furnizor_id) VALUES
('Mouse Wireless', 'MW2023', 85.00, 1),
('Tastatura Mecanica', 'TM9001', 350.50, 1),
('Monitor 240Hz', 'M24Hz', 785.00, 3),
('Router Wifi 6', 'RW600', 400.50, 1),
('Hârtie A4 (Top)', 'HART01', 25.00, 2),
('Telefon Samsung S26', 'TSS26', 5500.00, 2),
('Webcam HD','WC20', 45.00, 4);

-- Inserare ArticoleCategorii (M:N)
INSERT INTO ArticoleCategorii (articol_id, categorie_id) VALUES
(1000, 1), -- Mouse Wireless - Electronic
(1000, 2), -- Mouse Wireless - Componente <-- **INTERSECT Functioneaza Aici**
(1001, 1), -- Tastatura - Electronic
(1001, 2), -- Tastatura - Componente
(1005, 3), -- Hârtie A4 - Consumabil
(1003, 4), -- Router Wifi - Accesorii
(1006, 5); -- Telefon - Premium

-- Inserare Tipuri Tranzactii
INSERT INTO TipuriTranzactii (nume_tip) VALUES
('IN - Aprovizionare'),
('OUT - Vanzare');


-- Articol 1000 (Mouse) -> Raft A1
INSERT INTO Stoc (articol_id, locatie_id, cantitate) VALUES
(1000, 1, 100); 

-- Articol 1002 (Hartie) -> Depozitul Principal
INSERT INTO Stoc (articol_id, locatie_id, cantitate) VALUES
(1002, 3, 500);

 -- Records the transaction for the Mouse entry
INSERT INTO Tranzactii (articol_id, cantitate_schimbata, tip_tranzactie_id, utilizator_id) VALUES
(1000, 100, 1, 1);

-- Records another transaction for the expensive phone
INSERT INTO Tranzactii (articol_id, cantitate_schimbata, tip_tranzactie_id, utilizator_id) VALUES
(1006, 10, 1, 2);

--!!EROAREA!!
-- This statement attempts to use a non-existent furnizor_id (999) and will fail.
INSERT INTO Articole(nume_articol,cod_sku,pret_curent,furnizor_id) VALUES
('Casti Wrieless','CW200',200.00,999);
GO


-- UPDATE 
-- UPDATE: Applies a 10% discount to articles priced > 400 AND whose name ends with 'R'
UPDATE Articole
SET pret_curent = pret_curent * 0.90
WHERE pret_curent > 400.00 AND nume_articol LIKE '%R'; --ex:router
GO

-- Increases stock quantity by 10% for items with high or low current stock
UPDATE Stoc
SET cantitate = cantitate * 1.10
WHERE cantitate > 100.00 OR cantitate < 50.00;  
GO

-- Corrects stock quantity to 10 where it is zero (or where location is NULL, if applicable)
UPDATE Stoc
SET cantitate = 10
WHERE cantitate = 0 OR locatie_id = NULL;
GO


-- Marks suppliers without a contact email as [REG]ional
UPDATE Furnizori 
SET nume = nume + ' [REG]'
WHERE contact_email IS NULL AND nume NOT LIKE '%[REG]'; --add reg to the AMBALAJE PROFI
GO
 

 --DELETE

 -- DELETE: Deletes old price history (rows 1-10) for cheap articles (< 50.00)
 DELETE FROM IstoricPreturi
 WHERE istoric_id BETWEEN 1 AND 10
         AND articol_id IN(
         SELECT articol_id
         FROM Articole
         WHERE pret_curent < 50.00
         );
GO

-- Removes M:N links for Consumabile OR specifically for Article 1002 (Paper A4)
DELETE FROM ArticoleCategorii
WHERE categorie_id in(
SELECT categorie_id FROM Categorii WHERE nume = 'Consumabile'
) 
OR articol_id = 1002; --hartia A4
Go

--a. UNION ALL
-- Shows expensive products OR suppliers with defined email
SELECT nume_articol AS Nume_Obiect,'Articol' AS Tip
FROM Articole
WHERE pret_curent > 700.00
UNION ALL
SELECT nume AS Nume_Obiect,'Furnizor' AS Tip
FROM Furnizori
WHERE contact_email IS NOT NULL; 
GO

--OR
-- Finds very cheap OR very expensive articles
SELECT  nume_articol, pret_curent
FROM Articole
WHERE pret_curent < 100.00 OR pret_curent > 300.00
ORDER BY pret_curent DESC;
GO

--subpunct b
--INTERSECT - Finds articles classified as BOTH 'Electronice' AND 'Componente'  

SELECT articol_id
FROM ArticoleCategorii
WHERE categorie_id = (SELECT categorie_id FROM Categorii WHERE nume = 'Electronice')
INTERSECT 
SELECT articol_id
FROM ArticoleCategorii
WHERE categorie_id = (SELECT categorie_id FROM Categorii WHERE nume = 'Componente');
GO

--IN  - Finds suppliers that deliver expensive articles (> 300.00)
SELECT nume, contact_email
FROM Furnizori
WHERE furnizor_id IN (
    SELECT DISTINCT furnizor_id
    FROM Articole
    WHERE pret_curent > 300.00
);
GO


--subpnct c
--EXCEPT 
-- Finds suppliers who DO NOT deliver articles cheaper than 50 RON
SELECT furnizor_id
FROM Furnizori
EXCEPT
SELECT furnizor_id
FROM Articole
WHERE pret_curent < 50.00;
GO

--NOT IN
-- Finds locations that DO NOT store 'Consumabile'
SELECT nume_locatie
FROM Locatii
WHERE locatie_id NOT IN(
  SELECT DISTINCT L.locatie_id
  FROM Stoc AS S
  JOIN ArticoleCategorii AS AC ON S.articol_id = AC.articol_id
  JOIN Categorii AS C ON AC.categorie_id = C.categorie_id
  JOIN Locatii AS L ON S.locatie_id = L.locatie_id
  WHERE C.nume = 'Consumabile'
  );
  GO 

  --subpunct d
  --INNER JOIN
  -- Calculates total stock value for 'Electronice'
  SELECT 
    A.nume_articol,
    S.cantitate,
    A.pret_curent,
    (S.cantitate * A.pret_curent) AS Valoare_Totala_Stoc -- Expresie aritmetica
FROM 
    Stoc AS S
INNER JOIN Articole AS A ON S.articol_id = A.articol_id
INNER JOIN ArticoleCategorii AS AC ON A.articol_id = AC.articol_id
INNER JOIN Categorii AS C ON AC.categorie_id = C.categorie_id
WHERE 
    C.nume = 'Electronice'
ORDER BY Valoare_Totala_Stoc DESC;
GO

--LEFT JOIN
--Shows all suppliers and the count of articles they deliver (including 0)
SELECT 
    F.nume AS Nume_Furnizor,
    COUNT(A.articol_id) AS Numar_Articole_Livrate
FROM 
    Furnizori AS F
LEFT JOIN Articole AS A ON F.furnizor_id = A.furnizor_id
GROUP BY 
    F.nume
ORDER BY 
    Numar_Articole_Livrate DESC;
GO

--RIGHT JOIN 
--afiseaza toate locatiile si articolele din ele
SELECT 
    L.nume_locatie,
    A.nume_articol,
    S.cantitate
FROM 
    Stoc AS S
RIGHT JOIN Locatii AS L ON S.locatie_id = L.locatie_id
LEFT JOIN Articole AS A ON S.articol_id = A.articol_id -- LEFT JOIN pentru a aduce numele articolului
ORDER BY 
    L.nume_locatie;
GO

---FULL JOIN
-- Arata toate Articolele si toate Categoriile, evidentiind lipsurile
SELECT 
    A.nume_articol,
    C.nume AS Nume_Categorie,
    AC.articol_id -- Articol ID din tabela de legatura (va fi NULL acolo unde nu exista legatura)
FROM 
    Articole AS A
FULL JOIN ArticoleCategorii AS AC ON A.articol_id = AC.articol_id
FULL JOIN Categorii AS C ON AC.categorie_id = C.categorie_id
ORDER BY 
    A.nume_articol, C.nume;
GO


--subpunct e
--Subquery Simplu cu IN
-- gaseste articolele furnizate de 'GlobalTech Distributie'.
SELECT nume_articol, pret_curent
FROM Articole
WHERE furnizor_id IN (
    SELECT furnizor_id
    FROM Furnizori
    WHERE nume = 'GlobalTech Distributie'
)
ORDER BY nume_articol;
GO

--Nested Subquery
-- Gaseste Utilizatorii care au inregistrat tranzactii cu articole din categoria 'Electronice'.
SELECT nume_utilizator
FROM Utilizatori
WHERE utilizator_id IN ( -- Subquery nivel 1
    SELECT DISTINCT utilizator_id
    FROM Tranzactii
    WHERE articol_id IN ( -- Subquery nivel 2
        SELECT articol_id
        FROM ArticoleCategorii AS AC
        WHERE categorie_id = (SELECT categorie_id FROM Categorii WHERE nume = 'Electronice')
    )
);
GO

--subpunct f
--EXISTS 
--gaseste Furnizorii care au livrat cel putin un articol.
SELECT nume, contact_email
FROM Furnizori AS F
WHERE EXISTS (
    SELECT 1 
    FROM Articole AS A
    WHERE A.furnizor_id = F.furnizor_id -- Correlare
);
GO

-- NOT EXISTS
-- Gaseste Articolele care NU au inregistrat nicio tranzactie (vandute sau aprovizionate).
SELECT nume_articol, pret_curent
FROM Articole AS A
WHERE NOT EXISTS (
    SELECT 1 
    FROM Tranzactii AS T
    WHERE T.articol_id = A.articol_id -- Correlare
);
GO

--GROUP BY 
-- Numarul de articole livrate de fiecare furnizor
SELECT 
    F.nume AS Nume_Furnizor,
    COUNT(A.articol_id) AS Numar_Articole
FROM 
    Furnizori AS F
LEFT JOIN Articole AS A ON F.furnizor_id = A.furnizor_id
GROUP BY 
    F.nume
ORDER BY 
    Numar_Articole DESC;
GO
-- HHAVING 
-- Locatiile unde stocul total depaseste 150 unitati.
SELECT 
    L.nume_locatie,
    SUM(S.cantitate) AS Stoc_Total_Locatie
FROM 
    Locatii AS L
JOIN Stoc AS S ON L.locatie_id = S.locatie_id
GROUP BY 
    L.nume_locatie
HAVING 
    SUM(S.cantitate) > 150
ORDER BY 
    Stoc_Total_Locatie DESC;
GO
--  GROUP BY w HAVING (Subquery)
-- Categoriile cu pret mediu mai mare decat pretul mediu general al tuturor articolelor.
SELECT 
    C.nume AS Nume_Categorie,
    AVG(A.pret_curent) AS Pret_Mediu_Categorie
FROM 
    Categorii AS C
JOIN ArticoleCategorii AS AC ON C.categorie_id = AC.categorie_id
JOIN Articole AS A ON AC.articol_id = A.articol_id
GROUP BY 
    C.nume
HAVING 
    AVG(A.pret_curent) > (
        SELECT AVG(pret_curent) FROM Articole -- Subquery: Media generala
    )
ORDER BY 
    Pret_Mediu_Categorie DESC;
GO
--  GROUP BY w HAVING (COUNT DISTINCT si Subquery)
-- Furnizorii care livreaza articole stocate in mai mult de 1 locatie.
SELECT 
    F.nume AS Nume_Furnizor,
    COUNT(DISTINCT S.locatie_id) AS Locatii_Stoc_Distincte
FROM 
    Furnizori AS F
JOIN Articole AS A ON F.furnizor_id = A.furnizor_id
JOIN Stoc AS S ON A.articol_id = S.articol_id
GROUP BY 
    F.nume
HAVING 
    COUNT(DISTINCT S.locatie_id) > 1 
    AND F.furnizor_id = (SELECT MIN(furnizor_id) FROM Furnizori); -- Conditie pentru a folosi Subquery in HAVING
GO
s
--ALL 
-- Finds items more expensive than ALL consumables
SELECT nume_articol, pret_curent
FROM Articole
WHERE pret_curent > ALL (
    SELECT A.pret_curent
    FROM Articole AS A
    JOIN ArticoleCategorii AS AC ON A.articol_id = AC.articol_id
    WHERE AC.categorie_id = (SELECT categorie_id FROM Categorii WHERE nume = 'Consumabile')
);  


--rescris cu MAX :
SELECT nume_articol, pret_curent
FROM Articole
WHERE pret_curent > (
    SELECT MAX(A.pret_curent)
    FROM Articole AS A
    JOIN ArticoleCategorii AS AC ON A.articol_id = AC.articol_id
    WHERE AC.categorie_id = (SELECT categorie_id FROM Categorii WHERE nume = 'Consumabile')
)
ORDER BY pret_curent DESC;
GO

-- gaseste utilizatorii care NU au tranzactii cu Furnizorul Local
-- ANY:

SELECT nume_utilizator
FROM Utilizatori AS U
WHERE U.utilizator_id <> ANY (
    SELECT T.utilizator_id
    FROM Tranzactii AS T
    JOIN Articole AS A ON T.articol_id = A.articol_id
    JOIN Furnizori AS F ON A.furnizor_id = F.furnizor_id
    WHERE F.nume = 'Furnizorul Local SRL'
);


-- Versicon wiht NOT IN 
SELECT nume_utilizator
FROM Utilizatori
WHERE utilizator_id NOT IN (
    SELECT DISTINCT T.utilizator_id
    FROM Tranzactii AS T
    JOIN Articole AS A ON T.articol_id = A.articol_id
    JOIN Furnizori AS F ON A.furnizor_id = F.furnizor_id
    WHERE F.nume = 'Furnizorul Local SRL'
);
GO





-- 5: select
-- Show the curr. stoc,location and category
SELECT 
    A.nume_articol AS Articol,
    S.cantitate AS Stoc_Curent,
    L.nume_locatie AS Locatie,
    F.nume AS Furnizor, 
    C.nume AS Categorie
FROM 
    Stoc AS S
JOIN 
    Articole AS A ON S.articol_id = A.articol_id
JOIN 
    Locatii AS L ON S.locatie_id = L.locatie_id
JOIN 
    Furnizori AS F ON A.furnizor_id = F.furnizor_id
LEFT JOIN 
    ArticoleCategorii AS AC ON A.articol_id = AC.articol_id
LEFT JOIN
    Categorii AS C ON AC.categorie_id = C.categorie_id
ORDER BY 
    A.articol_id, C.nume;

