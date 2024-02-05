-- 1. Napisz polecenie, które oblicza wartość sprzedaży dla każdego zamówienia
-- w tablicy order details i zwraca wynik posortowany w malejącej kolejności
-- (wg wartości sprzedaży).
SELECT OrderID, SUM((Quantity*UnitPrice*(1-Discount))) AS COST FROM [Order Details]
GROUP BY OrderID
ORDER BY COST DESC

-- 2. Zmodyfikuj zapytanie z poprzedniego punktu, tak aby zwracało pierwszych
-- 10 wierszy
SELECT TOP 10 OrderID, SUM((Quantity*UnitPrice*(1-Discount))) AS COST FROM [Order Details]
GROUP BY OrderID
ORDER BY COST DESC


--1. Podaj liczbę zamówionych jednostek produktów dla produktów, dla których
-- productid < 3
SELECT ProductID, COUNT(*) AS ProductsAmount FROM [Order Details]
GROUP BY ProductID
HAVING ProductID < 3;

-- 2. Zmodyfikuj zapytanie z poprzedniego punktu, tak aby podawało liczbę
-- zamówionych jednostek produktu dla wszystkich produktów
SELECT ProductID, COUNT(*) AS ProductsAmount FROM [Order Details]
GROUP BY ProductID

-- 3. Podaj nr zamówienia oraz wartość zamówienia, dla zamówień, dla których
-- łączna liczba zamawianych jednostek produktów jest > 250
SELECT OrderID, Sum(Quantity*UnitPrice*(1-Discount)) AS Price FROM [Order Details]
GROUP BY OrderID
HAVING  Sum(Quantity)>250

-- 1. Dla każdego pracownika podaj liczbę obsługiwanych przez niego zamówień
SELECT CONCAT(FirstName,' ', LastName) as Name, COUNT(OrderID) AS OrdersAmount FROM Employees
LEFT OUTER JOIN Orders
ON Employees.EmployeeID = Orders.EmployeeID
GROUP BY CONCAT(FirstName,' ', LastName)


-- 2. Dla każdego spedytora/przewoźnika podaj wartość "opłata za przesyłkę"
-- przewożonych przez niego zamówień
SELECT CompanyName, SUM(Freight) AS FreightSum FROM Shippers
LEFT OUTER JOIN Orders
ON Shippers.ShipperID = Orders.ShipVia
GROUP BY CompanyName

-- 3. Dla każdego spedytora/przewoźnika podaj wartość "opłata za przesyłkę"
-- przewożonych przez niego zamówień w latach o 1996 do 1997
SELECT CompanyName, SUM(Freight) AS FreightSum FROM Shippers
LEFT OUTER JOIN Orders
ON Shippers.ShipperID = Orders.ShipVia
WHERE YEAR(ShippedDate) BETWEEN 1996 AND 1997
GROUP BY CompanyName


-- 1. Dla każdego pracownika podaj liczbę obsługiwanych przez niego zamówień z
-- podziałem na lata i miesiące
SELECT CONCAT(FirstName,' ', LastName) as Name, YEAR(ShippedDate) AS YEAR, MONTH(ShippedDate) AS MONTH, COUNT(*) AS OrdersAmount
FROM Orders
INNER JOIN Employees
ON Orders.EmployeeID = Employees.EmployeeID
GROUP BY CONCAT(FirstName,' ', LastName), YEAR(ShippedDate), MONTH(ShippedDate) 
WITH ROLLUP
ORDER BY Name, [YEAR], [MONTH];   

-- 2. Dla każdej kategorii podaj maksymalną i minimalną cenę produktu w tej
-- kategorii
SELECT CategoryName, MAX(UnitPrice) AS MaxPrice, MIN(UnitPrice) AS MinPrice
FROM Products
INNER JOIN Categories
ON Products.CategoryID = Categories.CategoryID
GROUP BY CategoryName 
