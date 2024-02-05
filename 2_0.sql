-- 1. Podaj liczbę produktów o cenach mniejszych niż 10$ lub większych niż 20$
SELECT COUNT(*) FROM Products
WHERE UnitPrice < 10 OR UnitPrice > 20

-- 2. Podaj maksymalną cenę produktu dla produktów o cenach poniżej 20$
SELECT MAX(UnitPrice) FROM Products
WHERE UnitPrice < 20

-- 3. Podaj maksymalną i minimalną i średnią cenę produktu dla produktów o produktach
-- sprzedawanych w butelkach (‘bottle’)
SELECT MAX(UnitPrice) AS Max, MIN(UnitPrice) AS Min, AVG(UnitPrice) AS Avg FROM Products
WHERE QuantityPerUnit LIKE '%bottles%'

-- 4. Wypisz informację o wszystkich produktach o cenie powyżej średniej
SELECT * FROM Products
WHERE UnitPrice < (SELECT AVG(UnitPrice) FROM Products)

-- 5. Podaj sumę/wartość zamówienia o numerze 10250
SELECT Round(SUM(Quantity*UnitPrice*(1-Discount)),2) FROM [Order Details]
WHERE OrderID = 10250
SELECT CAST(SUM(Quantity*UnitPrice*(1-Discount)) AS DECIMAL(10,2)) FROM [Order Details]
WHERE OrderID = 10250

-- 1. Podaj maksymalną cenę zamawianego produktu dla każdego zamówienia
SELECT OrderID, MAX(UnitPrice) AS the_most_valueable FROM [Order Details]
GROUP BY OrderID

-- 2. Posortuj zamówienia wg maksymalnej ceny produktu
SELECT OrderID, MAX(UnitPrice) AS max_value FROM [Order Details]
GROUP BY OrderID
ORDER BY max_value DESC

-- 3. Podaj maksymalną i minimalną cenę zamawianego produktu dla każdego zamówienia
SELECT OrderID, MAX(UnitPrice) AS the_most_valueable, MIN(UnitPrice) AS the_least_valueable FROM [Order Details]
GROUP BY OrderID

-- 4. Podaj liczbę zamówień dostarczanych przez poszczególnych spedytorów (przewoźników)
SELECT ShipVia,COUNT(*) FROM Orders
GROUP BY ShipVia

-- 5. Który z spedytorów był najaktywniejszy w 1997 roku
SELECT TOP 1 ShipVia FROM Orders
where YEAR(OrderDate) = 1997
GROUP BY ShipVia
ORDER BY COUNT(*) DESC

-- 1. Wyświetl zamówienia dla których liczba pozycji zamówienia jest większa niż 5
SELECT OrderID,COUNT(*) FROM [Order Details] 
GROUP BY OrderID
HAVING COUNT(*) > 5

-- 2. Wyświetl klientów dla których w 1998 roku zrealizowano więcej niż 8 zamówień (wyniki posortuj malejąco wg
-- łącznej kwoty za dostarczenie zamówień dla każdego z klientów)
SELECT CustomerID, COUNT(*) AS OrderCount, SUM(Freight) AS TotalFreight
FROM Orders
WHERE YEAR(ShippedDate) =  1998
GROUP BY CustomerID
HAVING COUNT(*) > 8
ORDER BY TotalFreight DESC;
