-- 1. Wybierz nazwy i ceny produktów (baza northwind) o cenie jednostkowej pomiędzy 20.00 a 30.00, dla każdego
-- produktu podaj dane adresowe dostawcy
SELECT ProductName,UnitPrice,Suppliers.Address,Suppliers.City FROM Products
INNER JOIN Suppliers
ON Products.SupplierID=Suppliers.SupplierID
WHERE UnitPrice BETWEEN 20 AND 30


-- 2. Wybierz nazwy produktów oraz inf. o stanie magazynu dla produktów dostarczanych
-- przez firmę ‘Tokyo Tradersʼ
SELECT ProductName,UnitsInStock FROM Products
INNER JOIN Suppliers
ON products.SupplierID = Suppliers.SupplierID
WHERE CompanyName LIKE 'Tokyo Traders'


-- 3. Czy są jacyś klienci którzy nie złożyli żadnego zamówienia w 1997 roku, jeśli tak to
-- pokaż ich dane adresowe
SELECT Customers.CustomerID,CompanyName,Address FROM Customers
LEFT OUTER JOIN Orders
ON Customers.CustomerID = Orders.CustomerID AND YEAR(OrderDate) = 1997 
WHERE OrderDate IS NULL

select suppliers.companyname, shippers.companyname
from suppliers cross join shippers




-- ===========================================================================================================================================
-- TESTY

-- 5.3 Czy są jacyś klienci którzy nie złożyli żadnego zamówienia w 1997 roku, jeśli tak
-- to pokaż ich dane adresowe
SELECT c.CustomerID, c.Address FROM Customers c
EXCEPT
SELECT DISTINCT c.CustomerID, c.Address FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
WHERE YEAR(o.OrderDate) = 1997

SELECT c.CustomerID, c.Address FROM Customers c
WHERE c.CustomerID NOT IN (
    SELECT DISTINCT c.CustomerID FROM Customers c
    JOIN Orders o ON o.CustomerID = c.CustomerID
    WHERE YEAR(o.OrderDate) = 1997
)



SELECT P.ProductID, P.ProductName,(
    SELECT AVG(UnitPrice)
    FROM Products AS P3
), (SELECT AVG(UnitPrice)
    FROM Products AS P2
    WHERE P2.CategoryID = P.CategoryID
)
FROM Products AS P



-- 4. Dla każdego tytułu książki podaj ile razy ten tytuł był wypożyczany w 2001r
SELECT t.title, t.title_no, (
    SELECT COUNT(*) FROM loanhist l
    WHERE l.title_no = t.title_no AND YEAR(l.out_date) = 2001
) FROM title t
ORDER BY t.title


--podwladni
SELECT e.EmployeeID, e2.EmployeeID FROM Employees e
LEFT OUTER JOIN Employees e2 ON e2.ReportsTo = e.EmployeeID
WHERE e2.EmployeeID IS NOT NULL


;WITH emp as (SELECT e.EmployeeID, ISNULL((
    SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM orders o 
    LEFT OUTER JOIN [Order Details] od ON od.OrderID = o.OrderID
    WHERE o.EmployeeID = e.EmployeeID
),0) + ISNULL((
    SELECT SUM(o.Freight) FROM Orders o 
    WHERE o.EmployeeID = e.EmployeeID
),0) as earning FROM Employees e),
t2 as (
    SELECT e.EmployeeID,(
        SELECT MAX(o.OrderDate) FROM Orders o
        WHERE o.EmployeeID = e.EmployeeID 
    ) as date FROM Employees e
)
SELECT DISTINCT e.FirstName, e.LastName, earning, t2.date FROM Employees e
LEFT OUTER JOIN Employees e2 ON e2.ReportsTo = e.EmployeeID
JOIN emp ON emp.EmployeeID = e.EmployeeID
JOIN t2 ON t2.EmployeeID = e.EmployeeID
WHERE e2.EmployeeID IS NOT NULL


--  Dla każdego produktu podaj jego nazwę, cenę, średnią cenę wszystkich produktów
-- oraz różnicę między ceną produktu a średnią ceną wszystkich produktów
SELECT *, t.sr - t.UnitPrice FROM(
SELECT p.ProductName,(
    SELECT AVG(UnitPrice) FROM Products
) sr,(
    SELECT AVG(UnitPrice) FROM Products p2
    WHERE p2.CategoryID = p.CategoryID
) sr_cat, p.UnitPrice FROM Products p
) t


-- . Wybierz nazwy i numery telefonów klientów, którzy nie kupowali produktów z kategorii
-- Confections.
SELECT c.CompanyName,c.Phone FROM Customers c
WHERE c.CustomerID NOT IN (
    SELECT o.CustomerID FROM Orders o
    LEFT OUTER JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products p ON p.ProductID = od.ProductID
    JOIN Categories c ON c.CategoryID = p.CategoryID
    WHERE c.CategoryName = 'Confections'
)

-- Dla każdego klienta podaj imię i nazwisko pracownika, który w 1997r obsłużył
-- najwięcej jego zamówień, podaj także liczbę tych zamówień (jeśli jest kilku takich
-- pracownikow to wystarczy podać imię nazwisko jednego nich). Za datę obsłużenia
-- zamówienia należy przyjąć orderdate. Zbiór wynikowy powinien zawierać nazwę
-- klienta, imię i nazwisko pracownika oraz liczbę obsłużonych zamówień. (baza
-- northwind)
select t.CompanyName, MAX(t.FirstName) as 'imie pracownika', MAX(t.LastName) as 'nazwisko pracownika', MAX([liczba zamowien]) as 'liczba zamowien'
from (select c.CompanyName, e.FirstName, e.Lastname, e.EmployeeID, COUNT(*) as 'liczba zamowien'
    from Customers c
    join Orders o
    on c.CustomerID = o.CustomerID
    join Employees e
    on o.EmployeeID = e.EmployeeID
    where  YEAR(OrderDate) = 1997
    group by c.CompanyName, e.FirstName, e.Lastname, e.EmployeeID) as t
group by CompanyName


-- Podaj listę dzieci będących członkami biblioteki, które w dniu '2001-12-14'
-- zwróciły do biblioteki książkę o tytule 'Walking'. Zbiór wynikowy powinien zawierać
-- imię i nazwisko oraz dane adresowe dziecka. (baza library)
SELECT m.firstname, m.lastname, a.street FROM member m
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
WHERE m.member_no IN (
    SELECT lh.member_no  FROM loanhist lh
    JOIN title t ON t.title_no = lh.title_no
    WHERE title = 'Walking' AND lh.in_date >= '2001.12.14' AND lh.in_date < '2001.12.15'
)


-- Podaj tytuły książek zarezerwowanych przez dorosłych członków biblioteki
-- mieszkających w Arizonie (AZ). Zbiór wynikowy powinien zawierać imię i nazwisko
-- członka biblioteki, jego adres oraz tytuł zarezerwowanej książki. Jeśli jakaś osoba
-- dorosła mieszkająca w Arizonie nie ma zarezerwowanej żadnej książki to też
-- powinna znaleźć się na liście, a w polu przeznaczonym na tytuł książki powinien
-- pojawić się napis BRAK. (baza library)
SELECT m.firstname,m.lastname,ISNULL((
    SELECT STRING_AGG(t.title,', ') FROM reservation r
    LEFT OUTER JOIN item i ON i.isbn = r.isbn
    LEFT OUTER JOIN title t oN t.title_no = i.title_no
    WHERE r.member_no = m.member_no
),'BRAK') FROM member m
JOIN adult a ON a.member_no = m.member_no
WHERE a.[state] = 'AZ'


-- Napisz polecenie które wyświetla imiona i nazwiska dorosłych członków biblioteki,
-- mieszkających w Arizonie (AZ) lub Kalifornii (CA), których wszystkie dzieci są
-- urodzone przed '2000-10-14'
SELECT m.firstname, m.lastname FROM member m
JOIN adult a ON a.member_no = m.member_no
WHERE (a.[state] = 'AZ' OR a.[state] = 'CA') AND a.member_no NOT IN (
    SELECT j.adult_member_no FROM juvenile j
    WHERE j.birth_date >= '2000-10-14'
)


-- 3.1 Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłek nie dostarczała firma ‘United Packageʼ
SELECT c.CompanyName,c.Phone FROM Customers c
WHERE c.CustomerID NOT IN (
    SELECT o.CustomerID FROM Orders o
    JOIN Shippers s ON s.ShipperID = o.ShipVia
    WHERE YEAR(o.OrderDate) = 1997  and s.CompanyName = 'United Package'
)


-- Dla każdego pracownika podaj nazwę klienta, dla którego dany pracownik w 1997r
-- obsłużył najwięcej zamówień, podaj także liczbę tych zamówień (jeśli jest kilku
-- takich klientów to wystarczy podać nazwę jednego nich). Za datę obsłużenia
-- zamówienia należy przyjąć orderdate. Zbiór wynikowy powinien zawierać imię i
-- nazwisko pracownika, nazwę klienta, oraz liczbę obsłużonych zamówień. (baza
-- northwind)
SELECT t.FirstName, t.LastName, MAX(t.CompanyName), MAX(t.orders) FROM (
    SELECT e.FirstName, e.LastName, c.CompanyName, COUNT(*) orders FROM Orders o
    JOIN Employees e ON o.EmployeeID = e.EmployeeID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE  YEAR(o.OrderDate) = 1997 
    GROUP BY e.FirstName, e.LastName, c.CompanyName
) as t
GROUP BY t.FirstName, t.LastName


-- 1. Podaj produkty kupowane przez więcej niż jednego klienta
SELECT * FROM 
(SELECT p.ProductName,(
    SELECT COUNT(DISTINCT o.CustomerID) FROM [Order Details] od
    JOIN Orders o ON o.OrderID = od.OrderID
    WHERE od.ProductID = p .ProductID
) as customers FROM Products p) as t
WHERE t.customers>1


SELECT ProductName, customers
FROM (
    SELECT p.ProductName, COUNT(DISTINCT o.CustomerID)  as customers
    FROM Products p
    JOIN [Order Details] od ON od.ProductID = p.ProductID
    JOIN Orders o ON o.OrderID = od.OrderID
    JOIN Categories c ON c.CategoryID = p.CategoryID
    WHERE c.CategoryName = 'Confections' AND YEAR(o.OrderDate) = 1997
    GROUP BY p.ProductName
) as t
WHERE t.customers > 1;
