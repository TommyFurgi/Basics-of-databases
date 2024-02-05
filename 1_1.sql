-- 1.	Wybierz nazwy i adresy wszystkich klientów mających siedziby w Londynie
Select CompanyName FROM Customers
WHERE City LIKE 'London'

-- 2. Wybierz nazwy i adresy wszystkich klientów mających siedziby we Francji lub w Hiszpanii 
Select CompanyName,Country FROM Customers
WHERE Country IN ('France','Spain')

-- 3. Wybierz nazwy i ceny produktów o cenie jednostkowej pomiędzy 20.00 a 30.00 
SELECT *  FROM Products
WHERE UnitPrice BETWEEN 20.00 AND 30.00

-- 4. Wybierz nazwy i ceny produktów z kategorii 'Meat/Poultry' 
SELECT ProductName, UnitPrice FROM Products
WHERE CategoryID IN (SELECT CategoryID FROM Categories WHERE CategoryName = 'Meat/Poultry')

-- 5. Wybierz nazwy produktów oraz inf. o stanie magazynu dla produktów dostarczanych przez firmę ‘Tokyo Traders’ 6. Wybierz nazwy produktów których nie ma w magazynie
SELECT Products.ProductName, Products.UnitPrice
FROM Products INNER JOIN Categories ON Products.CategoryID = Categories.CategoryID
WHERE Categories.CategoryName = 'Meat/Poultry'

SELECT * FROM Products
WHERE SupplierID IN (SELECT SupplierID FROM Suppliers WHERE CompanyName = 'Tokyo Traders')


-- 1.	Szukamy informacji o produktach sprzedawanych w butelkach (‘bottle’) 
SELECT * FROM Products
WHERE QuantityPerUnit LIKE '%bottle%'


-- 2. Wyszukaj informacje o stanowisku pracowników, których nazwiska zaczynają się na literę z zakresu od B do L 
SELECT * FROM Employees
WHERE LastName LIKE '[B-L]%'

SELECT * FROM Employees
WHERE LastName >= 'B' AND LastName < 'M'

-- 4.	Wyszukaj informacje o stanowisku pracowników, których nazwiska zaczynają się na literę B lub L
SELECT Title FROM Employees
WHERE LastName LIKE '[BL]%'

-- 4.	Znajdź nazwy kategorii, które w opisie zawierają przecinek 
SELECT CategoryName FROM Categories
WHERE Description LIKE '%,%'

-- 5. Znajdź klientów, którzy w swojej nazwie mają w którymś miejscu słowo ‘Store’
SELECT * FROM Customers
WHERE CompanyName LIKE '%Store%'

-- 1.	Szukamy informacji o produktach o cenach mniejszych niż 10 lub większych niż 20
SELECT productname, unitprice FROM products
WHERE (unitPrice >= 10 AND UnitPrice <= 20)

-- 1.	Wybierz nazwy i kraje wszystkich klientów mających siedziby w Japonii (Japan) lub we Włoszech (Italy)
SELECT CompanyName,Country FROM Customers
WHERE Country IN ('Japan', 'Italy')

-- Napisz instrukcję select tak aby wybrać numer zlecenia, datę zamówienia, numer klienta dla wszystkich
-- niezrealizowanych jeszcze zleceń, dla których krajem odbiorcy jest Argentyna
SELECT OrderID, OrderDate, CustomerID FROM Orders
WHERE ShipCountry LIKE 'Argentina' AND (ShippedDate IS NULL OR ShippedDate > getdate())

SELECT getdate()

-- 1.	Wybierz nazwy i kraje wszystkich klientów, wyniki posortuj według kraju, w ramach danego kraju nazwy firm posortuj alfabetycznie 
SELECT * FROM Customers
ORDER BY Country,CompanyName 

-- 2. Wybierz informację o produktach (grupa, nazwa, cena), produkty posortuj wg grup a w grupach malejąco wg ceny 
SELECT CategoryID,ProductName,UnitPrice FROM Products
ORDER BY CategoryID, UnitPrice


-- 3. Wybierz nazwy i kraje wszystkich klientów mających siedziby w Japonii (Japan) lub we Włoszech (Italy), wyniki posortuj tak jak w pkt 1
SELECT CompanyName,Country FROM Customers
WHERE Country = 'Japan' OR Country = 'Italy'
ORDER BY 2,1

-- 1. Napisz polecenie, które oblicza wartość każdej pozycji zamówienia o numerze 10250
SELECT OrderID,UnitPrice,Quantity, (Quantity * UnitPrice) AS Value
FROM [Order Details]
WHERE OrderID = 10250

-- 2. Napisz polecenie które dla każdego dostawcy (supplier) pokaże pojedynczą kolumnę zawierającą nr telefonu i
-- nr faksu w formacie
-- (numer telefonu i faksu mają być oddzielone przecinkiem)
SELECT CONCAT(Phone, ', ', Fax) AS PhoneAndFax
FROM Suppliers;
