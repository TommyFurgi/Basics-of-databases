-- 1. Dla każdego zamówienia podaj łączną liczbę zamówionych jednostek towaru oraz
-- nazwę klienta.
SELECT Customers.CustomerID, ContactName, Orders.OrderID, SUM([Order Details].Quantity) FROM Customers
INNER JOIN Orders ON Orders.CustomerID = Customers.CustomerID
INNER JOIN [Order Details] ON [Order Details].OrderID = Orders.OrderID
GROUP BY Customers.CustomerID, Customers.ContactName, Orders.OrderID


-- 2. Zmodyfikuj poprzedni przykład, aby pokazać tylko takie zamówienia, dla których
-- łączna liczbę zamówionych jednostek jest większa niż 250
SELECT Customers.CustomerID, ContactName, Orders.OrderID, SUM([Order Details].Quantity) as jednostki FROM Customers
INNER JOIN Orders ON Orders.CustomerID = Customers.CustomerID
INNER JOIN [Order Details] ON [Order Details].OrderID = Orders.OrderID
GROUP BY Customers.CustomerID, Customers.ContactName, Orders.OrderID
HAVING SUM([Order Details].Quantity) >250


-- 3. Dla każdego zamówienia podaj łączną wartość tego zamówienia oraz nazwę klienta.
SELECT Orders.OrderID, ContactName, SUM(Quantity * UnitPrice * (1-Discount)) as price FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID
INNER JOIN [Order Details] ON [Order Details].OrderID = Orders.OrderID
GROUP BY orders.OrderID, ContactName

-- 4. Zmodyfikuj poprzedni przykład, aby pokazać tylko takie zamówienia, dla których
-- łączna liczba jednostek jest większa niż 250.
SELECT Orders.OrderID, ContactName, SUM(Quantity * UnitPrice * (1-Discount)) as price FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID
INNER JOIN [Order Details] ON [Order Details].OrderID = Orders.OrderID
GROUP BY orders.OrderID, ContactName
HAVING SUM(Quantity) > 250

-- 5. Zmodyfikuj poprzedni przykład tak żeby dodać jeszcze imię i nazwisko pracownika
-- obsługującego zamówień
SELECT Orders.OrderID, ContactName, CONCAT(FirstName, ' ', LastName) as Name, SUM(Quantity * UnitPrice * (1-Discount)) as price FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID
INNER JOIN [Order Details] ON [Order Details].OrderID = Orders.OrderID
INNER JOIN Employees ON Employees.EmployeeID = Orders.EmployeeID
GROUP BY orders.OrderID, ContactName, CONCAT(FirstName, ' ', LastName)
HAVING SUM(Quantity) > 250


-- 1. Dla każdej kategorii produktu (nazwa), podaj łączną liczbę zamówionych przez
-- klientów jednostek towarów z tek kategorii.
SELECT Categories.CategoryName, SUM(Quantity) FROM Categories
INNER JOIN Products ON Products.CategoryID = Categories.CategoryID 
INNER JOIN [Order Details] ON [Order Details].ProductID = Products.ProductID
GROUP BY Categories.CategoryName

-- 2. Dla każdej kategorii produktu (nazwa), podaj łączną wartość zamówionych przez
-- klientów jednostek towarów z tek kategorii.
SELECT Categories.CategoryName, SUM(Quantity * [Order Details].UnitPrice * (1-Discount)) FROM Categories
INNER JOIN Products ON Products.CategoryID = Categories.CategoryID 
INNER JOIN [Order Details] ON [Order Details].ProductID = Products.ProductID
GROUP BY Categories.CategoryName

-- 3. Posortuj wyniki w zapytaniu z poprzedniego punktu wg:
-- a) łącznej wartości zamówień
-- b) łącznej liczby zamówionych przez klientów jednostek towarów.
SELECT Categories.CategoryName, SUM(Quantity * [Order Details].UnitPrice * (1-Discount)) as value FROM Categories
INNER JOIN Products ON Products.CategoryID = Categories.CategoryID 
INNER JOIN [Order Details] ON [Order Details].ProductID = Products.ProductID
GROUP BY Categories.CategoryName 
ORDER BY value

SELECT Categories.CategoryName, SUM(Quantity * [Order Details].UnitPrice * (1-Discount)) as value FROM Categories
INNER JOIN Products ON Products.CategoryID = Categories.CategoryID 
INNER JOIN [Order Details] ON [Order Details].ProductID = Products.ProductID
GROUP BY Categories.CategoryName 
ORDER BY COUNT(Quantity)

-- 4. Dla każdego zamówienia podaj jego wartość uwzględniając opłatę za przesyłkę
SELECT Orders.OrderID, SUM(Quantity * [Order Details].UnitPrice * (1-Discount)) + Freight as value FROM Orders
LEFT OUTER JOIN [Order Details] ON [Order Details].OrderID = Orders.OrderID
GROUP BY Orders.OrderID, Freight


-- 1. Dla każdego przewoźnika (nazwa) podaj liczbę zamówień które przewieźli w 1997r
SELECT CompanyName, COUNT(orders.ShippedDate) FROM Shippers
LEFT OUTER JOIN Orders ON Shippers.ShipperID = Orders.ShipVia AND  year(Orders.OrderDate) = 1997 
GROUP BY CompanyName

-- 2. Który z przewoźników był najaktywniejszy (przewiózł największą liczbę zamówień) w
-- 1997r, podaj nazwę tego przewoźnika

SELECT TOP 1 CompanyName FROM Shippers
LEFT OUTER JOIN Orders ON Shippers.ShipperID = Orders.ShipVia AND  year(Orders.OrderDate) = 1997 
GROUP BY CompanyName
ORDER BY COUNT(orders.ShippedDate) DESC


-- 3. Dla każdego pracownika (imię i nazwisko) podaj łączną wartość zamówień
-- obsłużonych przez tego pracownika
SELECT FirstName, LastName, SUM(Quantity * [Order Details].UnitPrice * (1-Discount)) as value FROM Employees
INNER JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
INNER JOIN [Order Details] ON [Order Details].OrderID = Orders.OrderID
GROUP BY FirstName,LastName

-- 4. Który z pracowników obsłużył największą liczbę zamówień w 1997r, podaj imię i
-- nazwisko takiego pracownika
SELECT TOP 1 FirstName, LastName FROM Employees
INNER JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID AND YEAR(OrderDate) = 1997
GROUP BY FirstName,LastName
ORDER BY COUNT(OrderID) DESC


-- 5. Który z pracowników obsłużył najaktywniejszy (obsłużył zamówienia o największej
-- wartości) w 1997r, podaj imię i nazwisko takiego pracownika
SELECT TOP 1 FirstName, LastName FROM Employees
INNER JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID AND YEAR(OrderDate) = 1997
INNER JOIN [Order Details] ON [Order Details].OrderID = Orders.OrderID
ORDER BY (Quantity * [Order Details].UnitPrice * (1-Discount)) DESC


-- 1. Dla każdego pracownika (imię i nazwisko) podaj łączną wartość zamówień
-- obsłużonych przez tego pracownika
-- Ogranicz wynik tylko do pracowników
-- a) którzy mają podwładnych
-- b) którzy nie mają podwładnych
SELECT e.FirstName, e.LastName, SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalOrderValue
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE e.EmployeeID IN (SELECT DISTINCT ReportsTo FROM Employees)
GROUP BY e.FirstName, e.LastName


SELECT e.FirstName, e.LastName, SUM(Quantity * [Order Details].UnitPrice * (1-Discount)) as value FROM Employees as e
INNER JOIN Orders ON e.EmployeeID = Orders.EmployeeID
INNER JOIN [Order Details] ON [Order Details].OrderID = Orders.OrderID
LEFT OUTER JOIN Employees as p ON e.EmployeeID = p.ReportsTo 
WHERE p.EmployeeID IS NULL
GROUP BY e.FirstName, e.LastName



