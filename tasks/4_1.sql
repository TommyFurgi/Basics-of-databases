
-- 1. Podaj łączną wartość zamówienia o numerze 10250 (uwzględnij cenę za przesyłkę)
SELECT 
    (Select SUM((UnitPrice * Quantity * (1-Discount))) as price FROM [Order Details]
    WHERE OrderID=10250
    GROUP BY OrderID) + Freight
FROM orders
WHERE OrderID = 10250

-- 2. Podaj łączną wartość każdego zamówienia (uwzględnij cenę za przesyłkę)
SELECT o.OrderID, price+freight as total_price FROM (
    Select OrderID, SUM((UnitPrice * Quantity * (1-Discount))) as price FROM [Order Details] 
    GROUP BY OrderID
) as od
JOIN orders o ON o.OrderID = od.OrderID

SELECT o.OrderID, (
    Select SUM((UnitPrice * Quantity * (1-Discount))) 
    FROM [Order Details] od
    WHERE o.OrderID = od.OrderID
)+o.Freight FROM Orders o



-- 3. Dla każdego produktu podaj maksymalną wartość zakupu tego produktu
SELECT p.ProductName, od.price
FROM (
    SELECT ProductID, Max(UnitPrice * Quantity * (1 - Discount)) as price
    FROM [Order Details] 
    GROUP BY ProductID
) as od
JOIN Products p ON p.ProductID = od.ProductID


-- 4. Dla każdego produktu podaj maksymalną wartość zakupu tego produktu w 1997r
SELECT p.ProductName, od.price AS price
FROM (
    SELECT ProductID, MAX(UnitPrice * Quantity * (1 - Discount)) as price
    FROM [Order Details]
    WHERE OrderID IN (
        SELECT OrderID
        FROM Orders
        WHERE YEAR(OrderDate) = 1997
    )
    GROUP BY ProductID
) as od
JOIN Products p ON p.ProductID = od.ProductID


-- 1. Dla każdego klienta podaj łączną wartość jego zamówień (bez opłaty za przesyłkę) z
-- 1996r
SELECT ContactName, CompanyName, SUM(price) AS price
FROM (
    SELECT od.OrderID, price, CustomerID
    FROM (
        SELECT OrderID, SUM(UnitPrice * Quantity * (1 - Discount)) as price
        FROM [Order Details]
        GROUP BY OrderID
    ) as od
    JOIN Orders ON Orders.OrderID = od.OrderID
    WHERE YEAR(OrderDate) = 1996
) as o
JOIN Customers ON Customers.CustomerID = o.CustomerID
GROUP BY ContactName, CompanyName
-- ORDER BY ContactName
EXCEPT

SELECT ContactName, CompanyName, SUM(UnitPrice * Quantity * (1 - Discount)) as price FROM Orders
JOIN Customers ON Customers.CustomerID = Orders.CustomerID
JOIN [Order Details] ON [Order Details].OrderID = Orders.OrderID
WHERE YEAR(OrderDate) = 1996
GROUP BY ContactName, CompanyName
ORDER BY ContactName

SELECT * FROM ( -- chyba najprostsze
    SELECT CustomerID, c.ContactName,(
        SELECT SUM(UnitPrice * Quantity * (1 - Discount)) FROM Orders o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
        WHERE o.CustomerID = c.CustomerID AND YEAR(o.OrderDate)= 1996
    ) as Price
    FROM Customers c
) t
WHERE Price IS NOT NULL
ORDER BY ContactName

-- 2. Dla każdego klienta podaj łączną wartość jego zamówień (uwzględnij opłatę za
-- przesyłkę) z 1996r
SELECT * FROM (
    SELECT CustomerID, c.ContactName,(
        SELECT SUM(UnitPrice * Quantity * (1 - Discount)) FROM Orders o
        JOIN [Order Details] od ON od.OrderID = o.OrderID
        WHERE o.CustomerID = c.CustomerID AND YEAR(o.OrderDate)= 1996
    ) + (
        SELECT SUM(o.Freight) FROM Orders o 
        WHERE o.CustomerID = c.CustomerID AND YEAR(o.OrderDate)= 1996
    ) as Price
    FROM Customers c
) t
WHERE Price IS NOT NULL
ORDER BY ContactName

-- 3. Dla każdego klienta podaj maksymalną wartość zamówień złożonych przez tego
-- klienta w 1997r
SELECT ContactName, CompanyName, Max(price) AS price
FROM (
    SELECT od.OrderID, price, CustomerID
    FROM (
        SELECT OrderID, SUM(UnitPrice * Quantity * (1 - Discount)) as price
        FROM [Order Details]
        GROUP BY OrderID
    ) as od
    JOIN Orders ON Orders.OrderID = od.OrderID
    WHERE YEAR(OrderDate) = 1997
) as o
JOIN Customers ON Customers.CustomerID = o.CustomerID
GROUP BY ContactName, CompanyName
ORDER BY ContactName


SELECT c.ContactName, c.CompanyName, MAX(t.price) as maxPrice FROM Customers c
JOIN (
    SELECT o.OrderID, o.CustomerID, SUM(UnitPrice * Quantity * (1 - Discount)) as price FROM Orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    WHERE YEAR(o.OrderDate)= 1997
    GROUP BY o.OrderID, o.CustomerID
) as t ON t.CustomerID = c.CustomerID
GROUP BY c.ContactName, c.CompanyName
ORDER BY c.ContactName

SELECT c.CustomerID, ( -- najprostsze
    SELECT MAX(od.Quantity * od.UnitPrice * (1 - od.Discount)) 
    FROM Orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    WHERE o.CustomerID = c.CustomerID AND YEAR(o.OrderDate) = 1997
) AS maxPrice
FROM Customers c


-- 1. Dla każdego dorosłego członka biblioteki podaj jego imię, nazwisko oraz liczbę jego
-- dzieci.
SELECT m.member_no, firstname, lastname, COUNT(j.member_no) as kids FROM member m
JOIN juvenile j ON j.adult_member_no = m.member_no
GROUP BY m.member_no, firstname, lastname
ORDER BY m.member_no

SELECT m.member_no, m.firstname, m.lastname, (
    SELECT COUNT(*) FROM juvenile j 
    WHERE j.adult_member_no = a.member_no
) FROM adult a
JOIN member m on m.member_no = a.member_no


-- 2. Dla każdego dorosłego członka biblioteki podaj jego imię, nazwisko, liczbę jego dzieci,
-- liczbę zarezerwowanych książek oraz liczbę wypożyczonych książek.
;with t as (select a.member_no, count(j.member_no) as child_count
            from adult as a
                left outer join juvenile as j
                    on a.member_no = j.adult_member_no
            group by a.member_no
),
t1 as (
    select m.member_no, count(r.isbn) as res_count from member as m
    left outer join reservation as r on m.member_no = r.member_no
    group by m.member_no
),
t2 as (
    select m.member_no, count(l.isbn) as loan_count
            from member as m
                left outer join loan as l
                    on m.member_no = l.member_no
            group by m.member_no
)
select t.member_no, t.child_count, t1.res_count, t2.loan_count
from t
    join t1
        on t.member_no = t1.member_no
    join t2
        on t.member_no = t2.member_no
ORDER BY t.member_no ASC


SELECT m.member_no, (
    SELECT COUNT(*) FROM juvenile j 
    WHERE j.adult_member_no = a.member_no
) as child_count, (
    SELECT COUNT(*) FROM reservation r
    WHERE r.member_no = m.member_no
) as res_count, (
    SELECT COUNT(*) FROM loan l
    WHERE l.member_no = m.member_no
) as loan_count
FROM adult a
JOIN member m ON m.member_no = a.member_no;



-- 3. Dla każdego dorosłego członka biblioteki podaj jego imię, nazwisko, liczbę jego dzieci,
-- oraz liczbę książek zarezerwowanych i wypożyczonych przez niego i jego dzieci.
SELECT m.member_no, m.firstname, m.lastname,
       (
           SELECT COUNT(*) FROM juvenile j
           WHERE j.adult_member_no = m.member_no
       ) as child_count,
       (
           SELECT COUNT(*) FROM reservation r
           WHERE r.member_no = m.member_no
       ) as adult_res, (
           SELECT COUNT(*) FROM reservation r
           WHERE r.member_no IN (SELECT j.member_no FROM juvenile j WHERE j.adult_member_no = m.member_no)
       ) as cild_res,
       (
           SELECT COUNT(*) FROM loan l
           WHERE l.member_no = m.member_no
       ) as adult_loan, (
           SELECT COUNT(*) FROM loan l
           WHERE l.member_no IN (SELECT j.member_no FROM juvenile j WHERE j.adult_member_no = m.member_no)
       ) as child_loan 
FROM adult a
JOIN member m ON m.member_no = a.member_no;



select CONCAT_WS(' ', m.firstname, m.lastname)     "name",
       count(distinct j.member_no)                 "children count",
       count(distinct ra.isbn)                     "parent reservations",
       count(distinct rj.isbn)                     "children reservations",
       count(distinct CONCAT(la.isbn, la.copy_no)) "parent loan",
       count(distinct CONCAT(lj.isbn, lj.copy_no)) "children loan"
from adult a
         join member m on a.member_no = m.member_no
         left join juvenile j on j.adult_member_no = a.member_no
         left join reservation ra on a.member_no = ra.member_no
         left join reservation rj on rj.member_no = j.member_no
         left join loan la on a.member_no = la.member_no
         left join loan lj on lj.member_no = j.member_no
group by a.member_no, m.firstname, m.lastname;


-- 4. Dla każdego tytułu książki podaj ile razy ten tytuł był wypożyczany w 2001r
SELECT title, COUNT(h.title_no) FROM title t
JOIN loanhist h ON h.title_no=t.title_no
WHERE YEAR(h.out_date) = 2001
GROUP BY title
ORDER BY title

SELECT t.title,(
    SELECT COUNT(*) FROM loanhist
    WHERE loanhist.title_no = t.title_no 
    AND YEAR(loanhist.out_date) = 2001
) FROM title t
ORDER BY title


-- 5. Dla każdego tytułu książki podaj ile razy ten tytuł był wypożyczany w 2002r
SELECT title, COUNT(h.title_no) FROM title t -- ZLE
JOIN loanhist h ON h.title_no=t.title_no
WHERE YEAR(h.out_date) = 2002
GROUP BY title
ORDER BY title

SELECT title,(
    SELECT COUNT(*) FROM loanhist
    WHERE loanhist.title_no = t.title_no 
    AND YEAR(loanhist.out_date) = 2002
) + (
    SELECT COUNT(*) FROM loan
   WHERE loan.title_no = t.title_no 
    AND YEAR(loan.out_date) = 2002
)
FROM title t
ORDER BY title

-- 1. Czy są jacyś klienci którzy nie złożyli żadnego zamówienia w 1997 roku, jeśli tak to
-- pokaż ich dane adresowe
SELECT *
FROM Customers
WHERE CustomerID NOT IN (
    SELECT CustomerID
    FROM Orders
    WHERE YEAR(OrderDate) = 1997
)

SELECT c.CustomerID
FROM Customers c
WHERE (
    SELECT COUNT(*) FROM Orders o
    WHERE YEAR(OrderDate) = 1997 AND o.CustomerID = c.CustomerID
) = 0

-- 2. Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłki
-- dostarczała firma United Package.
SELECT CompanyName, Phone
FROM Customers
WHERE CustomerID IN (
    SELECT CustomerID
    FROM Orders
    WHERE YEAR(ShippedDate) = 1997 AND ShipVia IN (
        SELECT ShipperID FROM Shippers
        WHERE CompanyName = 'United Package'
    )
)


SELECT c.CompanyName, c.Phone FROM Customers c
INNER JOIN Orders ON Orders.CustomerID = c.CustomerID
INNER JOIN Shippers ON Shippers.ShipperID = Orders.ShipVia
WHERE Shippers.CompanyName = 'United Package' and YEAR(Orders.ShippedDate) = 1997


-- 3. Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłek nie
-- dostarczała firma United Package.
SELECT CompanyName, Phone
FROM Customers
WHERE CustomerID NOT IN (
    SELECT CustomerID
    FROM Orders
    WHERE YEAR(ShippedDate) = 1997 AND ShipVia IN (
        SELECT ShipperID FROM Shippers
        WHERE CompanyName = 'United Package'
    )
)


-- 4. Wybierz nazwy i numery telefonów klientów, którzy kupowali produkty z kategorii
-- Confections.

SELECT DISTINCT c.ContactName, c.Phone FROM [Order Details] od
INNER JOIN Orders o ON o.OrderID = od.OrderID
INNER JOIN Customers c ON c.CustomerID = o.CustomerID
INNER JOIN Products p ON p.ProductID = od.ProductID
INNER JOIN Categories ca ON p.CategoryID = ca.CategoryID
WHERE ca.CategoryName = 'Confections' 


-- 5. Wybierz nazwy i numery telefonów klientów, którzy nie kupowali produktów z kategorii
-- Confections.
SELECT c.ContactName, c.Phone FROM Customers c
EXCEPT 
SELECT DISTINCT c.ContactName, c.Phone FROM [Order Details] od
INNER JOIN Orders o ON o.OrderID = od.OrderID
INNER JOIN Customers c ON c.CustomerID = o.CustomerID
INNER JOIN Products p ON p.ProductID = od.ProductID
INNER JOIN Categories ca ON p.CategoryID = ca.CategoryID
WHERE ca.CategoryName = 'Confections' 

SELECT c.ContactName, c.Phone FROM Customers c
WHERE c.CustomerID NOT IN (
SELECT DISTINCT CustomerID FROM Orders o
INNER JOIN [Order Details] od ON od.OrderID = o.OrderID
INNER JOIN Products p ON p.ProductID = od.ProductID
INNER JOIN Categories ca ON p.CategoryID = ca.CategoryID
WHERE ca.CategoryName = 'Confections')

SELECT c.ContactName, c.Phone FROM Customers c
WHERE NOT EXISTS (
SELECT DISTINCT CustomerID FROM Orders o
INNER JOIN [Order Details] od ON od.OrderID = o.OrderID
INNER JOIN Products p ON p.ProductID = od.ProductID
INNER JOIN Categories ca ON p.CategoryID = ca.CategoryID
WHERE c.CustomerID = o.CustomerID and ca.CategoryName = 'Confections')


-- 1. Podaj wszystkie produkty których cena jest mniejsza niż średnia cena produktu
SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice < (
    SELECT AVG(UnitPrice) 
    FROM Products
    )


-- 2. Podaj wszystkie produkty których cena jest mniejsza niż średnia cena produktu danej
-- kategorii
SELECT p.ProductName, p.UnitPrice
FROM Products p
WHERE p.UnitPrice < (
    SELECT AVG(p2.UnitPrice)
    FROM Products p2
    WHERE p2.CategoryID = p.CategoryID
)

-- 3. Dla każdego produktu podaj jego nazwę, cenę, średnią cenę wszystkich produktów
-- oraz różnicę między ceną produktu a średnią ceną wszystkich produktów
SELECT p.ProductName, p.UnitPrice, avg_prices.avg_price AS AveragePrice, (p.UnitPrice - avg_prices.avg_price) AS PriceDifference
FROM Products p
CROSS JOIN (
    SELECT AVG(UnitPrice) AS avg_price
    FROM Products
) avg_prices

SELECT *, (t.UnitPrice - t.avg_price) FROM (
    SELECT p.ProductName, p.UnitPrice, (
        SELECT AVG(UnitPrice) AS avg_price
        FROM Products
    ) avg_price
    FROM Products p
) as t


select *, UnitPrice - average as diff from
(select productname, categoryid, unitprice
,(select avg(unitprice)
from products as p_in
where p_in.categoryid = p_out.categoryid ) as average
from products as p_out) p

-- 4. Dla każdego produktu podaj jego nazwę kategorii, nazwę produktu, cenę, średnią cenę
-- wszystkich produktów danej kategorii oraz różnicę między ceną produktu a średnią
-- ceną wszystkich produktów danej kategorii
SELECT ProductName, c.CategoryName, p.UnitPrice, (
    select avg(unitprice)
    from products as p_in
    where p_in.categoryid = c.categoryid 
    ) as average,
p.UnitPrice - (
        SELECT AVG(p_in.UnitPrice)
        FROM Products p_in
        WHERE p_in.CategoryID = c.CategoryID
    ) AS diff
FROM Products p
INNER JOIN Categories c ON c.CategoryID = p.CategoryID

SELECT *, UnitPrice - average as diff FROM(
    SELECT ProductName, c.CategoryName, p.UnitPrice, (
        select avg(unitprice)
        from products as p_in
        where p_in.categoryid = c.categoryid 
        ) as average
    FROM Products p
    INNER JOIN Categories c ON c.CategoryID = p.CategoryID
) t 


-- 1. Podaj produkty kupowane przez więcej niż jednego klienta
SELECT  ProductName,  COUNT(DISTINCT o.CustomerID) FROM Products p
LEFT OUTER JOIN [Order Details] od ON od.ProductID = p.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY ProductName
HAVING  COUNT(DISTINCT o.CustomerID) > 1
ORDER BY ProductName


-- 2. Podaj produkty kupowane w 1997r przez więcej niż jednego klienta
SELECT ProductName, COUNT(DISTINCT c.CustomerID) AS CustomerCount
FROM Products p
LEFT OUTER JOIN [Order Details] od ON od.ProductID = p.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Customers c ON c.CustomerID = o.CustomerID
WHERE YEAR(o.OrderDate) = 1997
GROUP BY ProductName
HAVING COUNT(DISTINCT c.CustomerID) > 1
ORDER BY ProductName

-- 3. Podaj nazwy klientów którzy w 1997r kupili co najmniej dwa różne produkty z kategorii
-- 'Confections'
SELECT c.CustomerID
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
LEFT OUTER JOIN [Order Details] od ON od.OrderID = o.OrderID
JOIN Products p ON p.ProductID = od.ProductID
JOIN Categories ca ON ca.CategoryID = p.CategoryID
WHERE YEAR(o.OrderDate) = 1997 AND ca.CategoryName = 'Confections'
GROUP BY c.CustomerID
HAVING COUNT(DISTINCT p.ProductName) > 1;


-- 1. Dla każdego pracownika (imię i nazwisko) podaj łączną wartość zamówień
-- obsłużonych przez tego pracownika (przy obliczaniu wartości zamówień uwzględnij
-- cenę za przesyłkę
SELECT e.FirstName, e.LastName, SUM(total) as total FROM Employees e
JOIN (SELECT o.EmployeeID, SUM(od.UnitPrice * od.Quantity * (1-od.Discount))+o.Freight as total FROM Orders o
    LEFT OUTER JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY o.EmployeeID, o.Freight
) as ordersValue ON ordersValue.EmployeeID = e.EmployeeID
GROUP BY e.FirstName, e.LastName -- zle 


SELECT E.FirstName + ' ' + E.LastName AS 'name', (
    SELECT SUM(OD.UnitPrice*od.quantity*(1-od.Discount))
    from Orders AS O
    INNER JOIN [Order Details] as OD ON O.OrderID = OD.OrderID
    WHERE E.EmployeeID = O.EmployeeID
 ) + (
    SELECT sum(O.Freight)
    from Orders as o
    WHERE o.EmployeeID = e.EmployeeID
 )
FROM Employees AS E --6.1


-- 2. Który z pracowników obsłużył najaktywniejszy (obsłużył zamówienie o największej
-- wartości) w 1997r, podaj imię i nazwisko takiego pracownika
SELECT e.FirstName, e.LastName, ordersValue.total FROM Employees e
JOIN (SELECT TOP 1 o.EmployeeID, o.OrderID,  SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) as total FROM Orders o
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    WHERE YEAR(o.orderdate) = 1997
    GROUP BY o.OrderID, o.EmployeeID
    ORDER BY total DESC
) as ordersValue ON ordersValue.EmployeeID = e.EmployeeID


-- 2. Który z pracowników obsłużył najaktywniejszy (obsłużył zamówienia o największej
-- wartości) w 1997r, podaj imię i nazwisko takiego pracownika
SELECT TOP 1 e.FirstName, e.LastName, ordersValue.total FROM Employees e
JOIN (SELECT o.EmployeeID, SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) as total FROM Orders o
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    WHERE YEAR(o.orderdate) = 1997
    GROUP BY o.EmployeeID
) as ordersValue ON ordersValue.EmployeeID = e.EmployeeID
ORDER BY ordersValue.total DESC

SELECT TOP 1  E.FirstName + ' ' + e.LastName as 'name', (
    SELECT SUM(OD.UnitPrice*od.quantity*(1-od.Discount))
    from Orders AS O
    INNER JOIN [Order Details] as OD ON O.OrderID = OD.OrderID
    WHERE E.EmployeeID = O.EmployeeID AND year(O.OrderDate) = 1997
) AS 'value'
FROM Employees as e
ORDER BY value DESC --6.2



-- 3. Ogranicz wynik z pkt 1 tylko do pracowników
-- a) którzy mają podwładnych
-- b) którzy nie mają podwładnych

SELECT DISTINCT e.FirstName, e.LastName, e.total FROM (
    SELECT e.EmployeeID, e.FirstName, e.LastName, SUM(total) as total FROM Employees e
    JOIN (SELECT o.EmployeeID, SUM(od.UnitPrice * od.Quantity * (1-od.Discount))+o.Freight as total FROM Orders o
        LEFT OUTER JOIN [Order Details] od ON o.OrderID = od.OrderID
        GROUP BY o.EmployeeID, o.Freight
    ) as ordersValue ON ordersValue.EmployeeID = e.EmployeeID
    GROUP BY e.FirstName, e.LastName, e.EmployeeID) as e
left outer JOIN Employees p
on p.ReportsTo=e.EmployeeID
where p.EmployeeID is NOT null

SELECT E.FirstName + ' ' + E.LastName AS 'name', (
    SELECT SUM(OD.UnitPrice*od.quantity*(1-od.Discount))
    from Orders AS O
    INNER JOIN [Order Details] as OD ON O.OrderID = OD.OrderID
    WHERE E.EmployeeID = O.EmployeeID
) +( 
    SELECT sum(O.Freight)
    from Orders as o
    WHERE o.EmployeeID = e.EmployeeID)
FROM Employees AS E
WHERE e.EmployeeID IN (select distinct a.EmployeeID
 from Employees as a
 inner join Employees as b on a.EmployeeID = b.ReportsTo)

-- B
SELECT e.FirstName, e.LastName, e.total FROM (
    SELECT e.EmployeeID, e.FirstName, e.LastName, SUM(total) as total FROM Employees e
    JOIN (SELECT o.EmployeeID, SUM(od.UnitPrice * od.Quantity * (1-od.Discount))+o.Freight as total FROM Orders o
        LEFT OUTER JOIN [Order Details] od ON o.OrderID = od.OrderID
        GROUP BY o.EmployeeID, o.Freight
    ) as ordersValue ON ordersValue.EmployeeID = e.EmployeeID
    GROUP BY e.FirstName, e.LastName, e.EmployeeID) as e
left outer JOIN Employees p
on p.ReportsTo=e.EmployeeID
where p.EmployeeID is null


SELECT E.FirstName + ' ' + E.LastName AS 'name', (
    SELECT SUM(OD.UnitPrice*od.quantity*(1-od.Discount))
    from Orders AS O
    INNER JOIN [Order Details] as OD ON O.OrderID = OD.OrderID
    WHERE E.EmployeeID = O.EmployeeID
) +( 
    SELECT sum(O.Freight)
    from Orders as o
    WHERE o.EmployeeID = e.EmployeeID)
FROM Employees AS E
WHERE e.EmployeeID IN (
    select distinct a.EmployeeID
    from Employees as a
    left join Employees as b on a.EmployeeID = b.ReportsTo
    WHERE b.EmployeeID IS NULL)
        
-- .....................................................................................................................................

-- Zad.1. Wyświetl produkt, który przyniósł najmniejszy, ale niezerowy, przychód w 1996 roku
SELECT * FROM(
    SELECT p.ProductName, SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) as suma FROM Products p
    LEFT OUTER JOIN [Order Details] od ON od.ProductID = p.ProductID
    LEFT OUTER JOIN Orders o ON o.OrderID = od.OrderID
    WHERE YEAR(o.OrderDate) = 1996
    GROUP BY p.ProductName
) as t
where t.suma >0
ORDER BY suma 


-- Zad.2. Wyświetl wszystkich członków biblioteki (imię i nazwisko, adres) 
-- rozróżniając dorosłych i dzieci (dla dorosłych podaj liczbę dzieci),
-- którzy nigdy nie wypożyczyli książki
SELECT m.firstname, m.lastname, a.street, (
    SELECT COUNT(j.adult_member_no) from juvenile j
    WHERE j.adult_member_no = a.member_no
) as dzieci FROM member m
JOIN adult a ON a.member_no = m.member_no
WHERE m.member_no NOT IN (select lh.member_no from loanhist lh) and m.member_no not in (select l.member_no from loan l)
UNION 
SELECT m.firstname, m.lastname, a.street, NULL as dzieci FROM member m
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
WHERE m.member_no NOT IN (select lh.member_no from loanhist lh) and m.member_no not in (select l.member_no from loan l)



-- Zad.3. Wyświetl podsumowanie zamówień (całkowita cena + fracht) obsłużonych 
-- przez pracowników w lutym 1997 roku, uwzględnij wszystkich, nawet jeśli suma 
-- wyniosła 0.

SELECT e.FirstName, e.LastName, ISNULL((
    SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM Orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    WHERE o.EmployeeID = e.EmployeeID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2 
),0) + ISNULL((
    SELECT SUM(o.Freight) FROM Orders o
    WHERE o.EmployeeID = e.EmployeeID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2 
),0) as suma FROM Employees e





SELECT t.FirstName, t.LastName, t.CompanyName, MAX(t.orders) FROM (
    SELECT e.FirstName, e.LastName, c.CompanyName, COUNT(*) orders FROM Orders o
    join Employees e ON o.EmployeeID = e.EmployeeID
    join Customers c ON c.CustomerID = o.CustomerID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY e.FirstName, e.LastName, c.CompanyName
) as t
GROUP BY t.FirstName, t.LastName, t.CompanyName


-- Podaj tytuły książek zarezerwowanych przez dorosłych członków biblioteki
-- mieszkających w Arizonie (AZ). Zbiór wynikowy powinien zawierać imię i nazwisko
-- członka biblioteki, jego adres oraz tytuł zarezerwowanej książki. Jeśli jakaś osoba
-- dorosła mieszkająca w Arizonie nie ma zarezerwowanej żadnej książki to też
-- powinna znaleźć się na liście, a w polu przeznaczonym na tytuł książki powinien
-- pojawić się napis BRAK. (baza library)
SELECT t.firstname, t.lastname, ISNULL(t.title,'BRAK') FROM 
(SELECT m.firstname, m.lastname, t.title  FROM member m
LEFT OUTER JOIN reservation r ON r.member_no = m. member_no
LEFT OUTER JOIN item i ON i.isbn = r.isbn
LEFT OUTER JOIN title t ON t.title_no = i.title_no
JOIN adult a ON a.member_no = m.member_no
WHERE a.[state] = 'AZ') as t

SELECT m.firstname, m.lastname, a.street,ISNULL((
    SELECT STRING_AGG(t.title,', ') FROM reservation r
    JOIN item i ON i.isbn = r.isbn 
    JOIN title t ON t.title_no = i.title_no
    WHERE r.member_no = m.member_no
),'BRAK') reserwavations FROM member m 
JOIN adult a ON a.member_no = m.member_no 
WHERE a.[state] = 'AZ'

-- Napisz polecenie które wyświetla imiona i nazwiska dorosłych członków biblioteki,
-- mieszkających w Arizonie (AZ) lub Kalifornii (CA), których wszystkie dzieci są
-- urodzone przed '2000-10-14'
SELECT m.firstname, m.lastname FROM member m
JOIN adult a ON a.member_no = m.member_no
WHERE (a.[state] = 'AZ' OR a.[state] = 'CA') AND m.member_no NOT IN(
    SELECT j.adult_member_no FROM juvenile j 
    WHERE j.birth_date >= '2000-10-14'
) AND m.member_no IN(
    SELECT j.adult_member_no FROM juvenile j 
)


-- Dla każdego dorosłego członka biblioteki podaj jego imię, nazwisko, liczbę jego dzieci,
-- liczbę zarezerwowanych książek oraz liczbę wypożyczonych książek.
SELECT m.firstname, m.lastname, (
    SELECT COUNT(*) FROM juvenile j
    WHERE j.adult_member_no = m.member_no
) as kids, (
    SELECT COUNT(*) FROM loan l
    WHERE l.member_no = m.member_no
)as on_loan, (
    SELECT COUNT(*) FROM reservation r
    WHERE r.member_no = m.member_no
)as reservations, (
    SELECT COUNT(*) FROM loan l
    WHERE l.member_no = j.adult_member_no
) FROM member m 
JOIN adult a ON a.member_no = m.member_no
JOIN juvenile j ON j.adult_member_no = a.member_no


-- Pokaż nazwy produktów, kategorii 'Beverages' które nie były kupowane w okresie
-- od '1997.02.20' do '1997.02.25' Dla każdego takiego produktu podaj jego nazwę,
-- nazwę dostawcy (supplier), oraz nazwę kategorii. Zbiór wynikowy powinien
-- zawierać nazwę produktu, nazwę dostawcy oraz nazwę kategorii. (baza northwind)
SELECT p.ProductName, s.CompanyName, c.CategoryName FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
JOIN Suppliers s ON s.SupplierID = p.SupplierID
WHERE c.CategoryName = 'Beverages' AND p.ProductID NOT in (
    SELECT p2.ProductID FROM Products p2
    JOIN Categories c ON c.CategoryID = p2.CategoryID
    JOIN [Order Details] od ON p2.ProductID = od.ProductID
    JOIN Orders o ON o.OrderID = od.OrderID
    WHERE o.OrderDate >= '1997.02.20' AND o.OrderDate < '1997.02.25'
)

-- Wyświetl numery zamówień złożonych w od marca do maja 1997, które były
-- przewożone przez firmę 'United Package' i nie zawierały produktów z kategorii
-- "confections". (baza northwind)
SELECT o.OrderID
FROM Orders o
JOIN Shippers s ON s.ShipperID = o.ShipVia
WHERE o.OrderDate >= '1997-03-01' AND o.OrderDate < '1997-06-01' AND s.CompanyName = 'United Package' AND o.OrderID NOT IN(
    SELECT o.OrderID FROM Orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products p ON p.ProductID = od.ProductID
    JOIN Categories c ON c.CategoryID = p.CategoryID
    WHERE c.CategoryName = 'confections'
)

-- Podaj nazwy produktów które w marcu 1997 nie były kupowane przez klientów z
-- Francji. Dla każdego takiego produktu podaj jego nazwę, nazwę kategorii do której
-- należy ten produkt oraz jego cenę.
SELECT p.ProductName, c.CategoryName, p.UnitPrice FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE p.ProductID NOT IN (
    SELECT od.ProductID FROM [Order Details] od
    JOIN Orders o ON o.OrderID = od.OrderID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE c.Country = 'France' AND YEAR(o.OrderDate) = 1997 AND MONTH(o.orderdate) = 3
)






;with Obsluzeni as (
    select Orders.CustomerID, FirstName, e.EmployeeID, LastName, count(Orders.OrderID) as LiczbaZamowien from Customers
    join Orders on Customers.CustomerID = Orders.CustomerID
    join Employees e on Orders.EmployeeID = e.EmployeeID
    where year(OrderDate)=1997
    group by Orders.CustomerID, FirstName, LastName, e.EmployeeID
), 
NajwiecejObsluzonych as (
    select CustomerID, FirstName, LastName, LiczbaZamowien, ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY LiczbaZamowien DESC, EmployeeID) as Rownosc
    from Obsluzeni
)
select Customers.CustomerID, FirstName, LastName, Rownosc
from Customers
left join NajwiecejObsluzonych N on Customers.CustomerID = N.CustomerID and N.Rownosc=1


;with t as(select distinct cu.CustomerID, firstname, lastname, (
    select top 1 count(orderId) from orders o
    where year(orderdate)=1997 and cu.customerid=o.CustomerID
    group by customerid,employeeid
    order by count(orderId) desc
) as orders_served from Customers cu
join orders ord on ord.CustomerID=cu.CustomerID
join Employees e on e.EmployeeID=ord.EmployeeID and e.EmployeeID in (
    select top 1 EmployeeID from orders orr
    where year(orderdate)=1997 and cu.customerid=orr.CustomerID
    group by customerid,employeeid
    order by count(orderId) desc
   ) 
)
select c.CompanyName,t.FirstName,t.LastName,t.orders_served from t 
right outer join customers c on c.CustomerID=t.CustomerID
order by c.CompanyName



;with t as (
    SELECT c.CompanyName, e.FirstName, e.LastName, COUNT(*) ilosc FROM orders o
    join Customers c ON o.CustomerID = c.CustomerID
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY c.CompanyName, e.FirstName, e.LastName
)
SELECT * FROM t


;WITH t AS (
    SELECT c.CompanyName, e.FirstName, e.LastName, COUNT(*) AS ilosc, ROW_NUMBER() OVER (PARTITION BY c.CompanyName ORDER BY COUNT(*) DESC) AS rn
    FROM Orders o
    JOIN Customers c ON o.CustomerID = c.CustomerID
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY c.CompanyName, e.FirstName, e.LastName
)
SELECT t.CompanyName, t.FirstName, t.LastName, t.ilosc FROM t
WHERE t.rn = 1;




;WITH t AS (
    SELECT e.FirstName, e.LastName, c.CustomerID, COUNT(*) as suma, ROW_NUMBER() OVER (PARTITION BY e.firstname, e.lastname order BY COUNT(*) DESC) as rank FROM Orders o
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY e.FirstName, e.LastName, c.CustomerID
)
SELECT * FROM t
WHERE t.rank = 1


-- Podaj listę członków biblioteki mieszkających w Arizonie (AZ) którzy mają więcej niż
-- dwoje dzieci zapisanych do biblioteki oraz takich którzy mieszkają w Kaliforni (CA) i
-- mają więcej niż troje dzieci zapisanych do biblioteki
SELECT m.member_no, m.firstname, m.lastname,(
    SELECT COUNT(*) FROM juvenile j
    WHERE j.adult_member_no = a.member_no
) FROM member m
JOIN adult a ON a.member_no = m.member_no
WHERE a.[state] = 'AZ' AND (
    SELECT COUNT(*) FROM juvenile j
    WHERE j.adult_member_no = a.member_no
)>2
UNION
SELECT m.member_no, m.firstname, m.lastname,(
    SELECT COUNT(*) FROM juvenile j
    WHERE j.adult_member_no = a.member_no
) FROM member m
JOIN adult a ON a.member_no = m.member_no
WHERE a.[state] = 'CA' AND (
    SELECT COUNT(*) FROM juvenile j
    WHERE j.adult_member_no = a.member_no
)>3


-- 1.a) Wyświetl imię, nazwisko, dane adresowe oraz ilość wypożyczonych książek dla każdego członka biblioteki. Ilość wypożyczonych książek nie może być nullem, co najwyżej zerem.
-- b) j/w + informacja, czy dany członek jest dzieckiem
SELECT m.member_no, m.firstname, m.lastname, a.street, (
    SELECT COUNT(*) FROM loan l
    WHERE l.member_no = m.member_no
), 'Adult' FROM member m
JOIN adult a ON a.member_no = m.member_no
UNION
SELECT m.member_no, m.firstname, m.lastname, a.street, (
    SELECT COUNT(*) FROM loan l
    WHERE l.member_no = m.member_no
), 'Cild' FROM member m
JOIN juvenile j ON m.member_no = j.member_no
JOIN adult a ON a.member_no = j.adult_member_no

SELECT * FROM loan

-- Podaj tytuły książek zarezerwowanych przez dorosłych członków biblioteki
-- mieszkających w Arizonie (AZ). Zbiór wynikowy powinien zawierać imię i nazwisko
-- członka biblioteki, jego adres oraz tytuł zarezerwowanej książki. Jeśli jakaś osoba
-- dorosła mieszkająca w Arizonie nie ma zarezerwowanej żadnej książki to też
-- powinna znaleźć się na liście, a w polu przeznaczonym na tytuł książki powinien
-- pojawić się napis BRAK. (baza library)
SELECT m.firstname, m.lastname, ISNULL(t.title,'BRAK') FROM member m
JOIN adult a ON a.member_no = m.member_no
LEFT OUTER JOIN reservation r ON r.member_no =m.member_no
LEFT OUTER JOIN item i ON i.isbn = r.isbn
LEFT OUTER JOIN title t ON t.title_no = i.title_no
WHERE a.[state] = 'AZ'


-- Dla każdego klienta podaj imię i nazwisko pracownika, który w 1997r obsłużył
-- najwięcej jego zamówień, podaj także liczbę tych zamówień (jeśli jest kilku takich
-- pracownikow to wystarczy podać imię nazwisko jednego nich). Zbiór wynikowy
-- powinien zawierać nazwę klienta, imię i nazwisko pracownika oraz liczbę
-- obsłużonych zamówień. (baza northwind)
;WITH t as (
    SELECT c.CompanyName, e.FirstName, e.LastName, COUNT(*) ilosc, ROW_NUMBER() OVER (PARTITION BY c.CompanyName order BY COUNT(*) DESC) as rank FROM Orders o
    JOIN Customers c ON c.CustomerID = o.CustomerID
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    WHERE YEAR(o.OrderDate) = 1997 
    GROUP BY c.CompanyName, e.FirstName, e.LastName
)
SELECT CompanyName, FirstName, LastName, ilosc FROM t
WHERE rank = 1


/* Napisz polecenie które wyświetla imiona i nazwiska dorosłych członków biblioteki,
mieszkających w Arizonie (AZ) lub Kalifornii (CA), których wszystkie dzieci są
urodzone przed '2000-10-14' */
SELECT m.firstname, m.lastname FROM member m
JOIN adult a ON a.member_no = m.member_no
WHERE (a.[state] = 'AZ' OR a.[state] = 'CA') AND m.member_no NOT IN (
    SELECT j.adult_member_no FROM juvenile j
    WHERE j.birth_date >= '2000-10-14'
) AND m.member_no IN (
    SELECT j.adult_member_no FROM juvenile j
)


-- Dla każdego pracownika podaj nazwę klienta, dla którego dany pracownik w 1997r
-- obsłużył najwięcej zamówień, podaj także liczbę tych zamówień (jeśli jest kilku
-- takich klientów to wystarczy podać nazwę jednego nich). Za datę obsłużenia
-- zamówienia należy przyjąć orderdate. Zbiór wynikowy powinien zawierać imię i
-- nazwisko pracownika, nazwę klienta, oraz liczbę obsłużonych zamówień. (baza
-- northwind)
;WITH t AS (
    SELECT e.FirstName, e.LastName, c.CompanyName, COUNT(*) as ilosc, ROW_NUMBER() OVER (PARTITION BY e.FirstName, e.LastName ORDER BY COUNT(*) DESC) rank FROM Orders o
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY e.FirstName, e.LastName, c.CompanyName
)
SELECT FirstName, LastName, CompanyName, ilosc FROM t
WHERE rank = 1


-- Wyświetl numery zamówień złożonych w od marca do maja 1997, które były
-- przewożone przez firmę 'United Package' i nie zawierały produktów z kategorii
-- "confections". (baza northwind)
SELECT o.OrderID FROM Orders o
WHERE o.OrderDate >= '1997.03.01' AND o.OrderDate < '1997.06.01' AND NOT EXISTS (
    SELECT o.OrderID FROM Orders o
    JOIN Shippers s ON s.ShipperID = o.ShipVia
    LEFT OUTER JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products p ON p.ProductID = od.ProductID
    JOIN Categories c ON c.CategoryID = p.CategoryID
    WHERE c.CategoryName = 'confections' OR s.CompanyName = 'United Package'
)

-- Podaj tytuły książek wypożyczonych (aktualnie) przez dzieci mieszkające w Arizonie
-- (AZ). Zbiór wynikowy powinien zawierać imię i nazwisko członka biblioteki
-- (dziecka), jego adres oraz tytuł wypożyczonej książki. Jeśli jakieś dziecko
-- mieszkająca w Arizonie nie ma wypożyczonej żadnej książki to też powinno znaleźć
-- się na liście, a w polu przeznaczonym na tytuł książki powinien pojawić się napis
-- BRAK. (baza library)
SELECT m.firstname, m.lastname, a.street, ISNULL((
    SELECT STRING_AGG(t.title,', ') FROM loan l
    LEFT OUTER JOIN title t ON t.title_no = l.title_no
    WHERE l.member_no = m.member_no
),'BRAK') as books  FROM member m
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
WHERE a.[state] = 'AZ'

SELECT m.firstname, m.lastname, a.street, ISNULL(t.title,'BRAK') as books FROM member m
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
LEFT OUTER JOIN loan l ON l.member_no = m.member_no 
LEFT OUTER JOIN title t ON t.title_no = l.title_no
WHERE a.[state] = 'AZ'

-- Dla każdego klienta podaj imię i nazwisko pracownika, który w 1997r obsłużył
-- najwięcej jego zamówień, podaj także liczbę tych zamówień (jeśli jest kilku takich
-- pracownikow to wystarczy podać imię nazwisko jednego nich). Zbiór wynikowy
-- powinien zawierać nazwę klienta, imię i nazwisko pracownika oraz liczbę
-- obsłużonych zamówień. (baza northwind)
WITH t AS (
    SELECT c.CompanyName, (e.FirstName + ' ' + e.LastName) as employee, COUNT(*) as ilosc, ROW_NUMBER() OVER (PARTITION BY c.companyname ORDER BY COUNT(*) DESC) as rank FROM orders o
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY c.CompanyName, e.FirstName, e.LastName
)
SELECT CompanyName, employee ,ilosc FROM t
WHERE rank = 1 

WITH t AS (
    SELECT c.CustomerID, (e.FirstName + ' ' + e.LastName) as employee, COUNT(*) as ilosc, ROW_NUMBER() OVER (PARTITION BY c.customerid ORDER BY COUNT(*) DESC) as rank FROM orders o
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY c.CustomerID, e.FirstName, e.LastName
)
SELECT c.CompanyName, t.employee, t.ilosc FROM Customers c
LEFT OUTER JOIN t ON t.CustomerID = c.CustomerID
WHERE rank = 1 OR ilosc IS NULL


-- Dla każdego produktu z kategorii 'confections' podaj wartość przychodu za ten
-- produkt w marcu 1997 (wartość sprzedaży tego produktu bez opłaty za przesyłkę).
-- Jeśli dany produkt (należący do kategorii 'confections') nie był sprzedawany w tym
-- okresie to też powinien pojawić się na liście (wartość sprzedaży w takim przypadku
-- jest równa 0) (baza northwind)
SELECT p.ProductName, ISNULL(SUM(od.Quantity*od.UnitPrice*(1-od.Discount)),0) AS zysk FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
LEFT OUTER JOIN [Order Details] od ON od.ProductID = p.ProductID
LEFT OUTER JOIN Orders o ON o.OrderID = od.OrderID 
WHERE c.CategoryName = 'confections' AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3
GROUP BY p.ProductName



SELECT p.ProductName, ISNULL((
    SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM [Order Details] od 
    LEFT OUTER JOIN Orders o ON o.OrderID = od.OrderID
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3 and p.ProductID = od.ProductID
),0) AS zysk FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE c.CategoryName = 'confections'

-- Podaj tytuły książek, które nie są aktualnie zarezerwowane przez dzieci mieszkające
-- w Arizonie (AZ). (baza library)
SELECT m.firstname, m.lastname, a.street, ISNULL((
    SELECT STRING_AGG(title,', ') FROM reservation r 
    LEFT OUTER JOIN item i ON i.isbn = r.isbn
    LEFT OUTER JOIN title t ON t.title_no = i.title_no
    WHERE r.member_no = m.member_no
),'BRAK') FROM member m
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
WHERE a.[state] = 'AZ'

SELECT m.firstname, m.lastname, a.street, ISNULL(title,'BRAK') FROM member m
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
LEFT OUTER JOIN reservation r ON r.member_no = m.member_no
LEFT OUTER JOIN item i ON i.isbn = r.isbn
LEFT OUTER JOIN title t ON t.title_no = i.title_no
WHERE a.[state] = 'AZ'


-- Dla każdego przewoźnika podaj nazwę produktu z kategorii 'Seafood', który ten
-- przewoźnik przewoził najczęściej w kwietniu 1997. Podaj też informację ile razy
-- dany przewoźnik przewoził ten produkt w tym okresie (jeśli takich produktów jest
-- więcej to wystarczy podać nazwę jednego z nich). Zbiór wynikowy powinien
-- zawierać nazwę przewoźnika, nazwę produktu oraz informację ile razy dany produkt
-- był przewożony (baza northwind)
;WITH t AS(
    SELECT s.CompanyName, p.ProductName, COUNT(*) as ile, ROW_NUMBER() OVER (PARTITION BY s.companyname ORDER BY COUNT(*) DESC) as RANK FROM Orders o 
    JOIN Shippers s ON s.ShipperID = o.ShipVia
    LEFT OUTER JOIN [Order Details] od ON od.OrderID = o.OrderID
    LEFT OUTER JOIN Products p ON p.ProductID = od.ProductID
    JOIN Categories c ON c.CategoryID = p.CategoryID
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 4 AND c.CategoryName = 'Seafood'
    GROUP BY s.CompanyName, p.ProductName
)
SELECT CompanyName, ProductName, ile FROM t
WHERE rank = 1

;WITH t AS(
    SELECT s.ShipperID, p.ProductName, COUNT(*) as ile, ROW_NUMBER() OVER (PARTITION BY s.ShipperID ORDER BY COUNT(*) DESC) as RANK FROM Orders o 
    JOIN Shippers s ON s.ShipperID = o.ShipVia
    LEFT OUTER JOIN [Order Details] od ON od.OrderID = o.OrderID
    LEFT OUTER JOIN Products p ON p.ProductID = od.ProductID
    JOIN Categories c ON c.CategoryID = p.CategoryID
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 4 AND c.CategoryName = 'Seafood' 
    GROUP BY s.ShipperID, p.ProductName
)
SELECT s.CompanyName, t.ProductName, t.ile FROM Shippers s
LEFT OUTER JOIN t ON t.ShipperID = s.ShipperID
WHERE rank = 1 OR t.ile IS NULL

-- 4. wyświetl ile każdy z przewoźników miał dostać wynagrodzenia w poszczególnych latach i miesiącach.
SELECT s.CompanyName, YEAR(o.OrderDate), MONTH(o.OrderDate), SUM(Freight)  FROM Orders o
JOIN Shippers s ON s.ShipperID = o.ShipVia
GROUP BY s.CompanyName, YEAR(o.OrderDate), MONTH(o.OrderDate) WITH ROLLUP

-- 3. wyświetl numery zamówień, których cena dostawy była większa niż średnia cena za przesyłkę w tym roku
SELECT o.OrderID FROM Orders o
WHERE o.Freight < (
    SELECT AVG(o2.Freight) FROM Orders o2
    WHERE YEAR(o2.OrderDate) = YEAR(o.OrderDate)
)

-- 2. wyświetl imiona i nazwiska osób, które nigdy nie wypożyczyły żadnej książki
SELECT m.firstname, m.lastname FROM member m
WHERE m.member_no NOT IN (
    SELECT member_no FROM loan
) AND m.member_no NOT IN (
    SELECT member_no FROM loanhist
)

-- 1.a) Wyświetl imię, nazwisko, dane adresowe oraz ilość wypożyczonych książek dla każdego członka biblioteki. Ilość wypożyczonych książek nie może być nullem, co najwyżej zerem.
SELECT m.member_no, m.firstname, m.lastname, a.street, 'ADULT', (
    SELECT COUNT(*) FROM loan l 
    WHERE m.member_no = l.member_no
) FROM member m 
JOIN adult a ON a.member_no = m.member_no
UNION 
SELECT m.member_no, m.firstname, m.lastname, a.street, 'CHILD', (
    SELECT COUNT(*) FROM loan l 
    WHERE m.member_no = l.member_no
) FROM member m 
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no


-- Wypisz wszystkich członków biblioteki z adresami i info czy jest dzieckiem czy nie i
-- ilość wypożyczeń w poszczególnych latach i miesiącach.
SELECT m.member_no, m.firstname, m.lastname, a.street, 'ADULT', YEAR(l.out_date), MONTH(l.out_date), COUNT(l.isbn) FROM member m 
JOIN adult a ON a.member_no = m.member_no
LEFT OUTER JOIN loan l ON l.member_no = m.member_no
GROUP BY  m.member_no, m.firstname, m.lastname, a.street, YEAR(l.out_date), MONTH(l.out_date) WITH ROLLUP
UNION 
SELECT m.member_no, m.firstname, m.lastname, a.street, 'ADULT', YEAR(l.out_date), MONTH(l.out_date), COUNT(l.isbn) FROM member m 
LEFT OUTER JOIN loan l ON l.member_no = m.member_no
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
GROUP BY  m.member_no, m.firstname, m.lastname, a.street, YEAR(l.out_date), MONTH(l.out_date) WITH ROLLUP

-- Klienci, którzy nie zamówili nigdy nic z kategorii 'Seafood' w trzech wersjach.
SELECT c.CompanyName FROM Customers c
WHERE c.CustomerID NOT IN (
    SELECT o.CustomerID FROM Orders o
    LEFT OUTER JOIN [Order Details] od ON od.OrderID = o. OrderID
    JOIN Products p ON p.ProductID = od.ProductID
    JOIN Categories c ON c.CategoryID = p.CategoryID
    WHERE c.CategoryName = 'Seafood'
)

SELECT c.CompanyName FROM Customers c
WHERE NOT EXISTS (
    SELECT 1 FROM Orders o
    LEFT JOIN [Order Details] od ON od.OrderID = o.OrderID
    LEFT JOIN Products p ON p.ProductID = od.ProductID
    LEFT JOIN Categories cat ON cat.CategoryID = p.CategoryID
    WHERE c.CustomerID = o.CustomerID AND cat.CategoryName = 'Seafood'
);


-- 4. Dla każdego klienta najczęściej zamawianą kategorię w dwóch wersjach.
;WITH t AS (
    SELECT c.CompanyName, ca.CategoryName, COUNT(*) AS ilosc, ROW_NUMBER() OVER (PARTITION BY c.companyname ORDER BY COUNT(*) DESC ) rank FROM Orders o 
    JOIN Customers c ON c.CustomerID = o.CustomerID
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products p ON p.ProductID = od.ProductID
    JOIN Categories ca ON ca.CategoryID = p.ProductID
    GROUP BY c.CompanyName, ca.CategoryName
)
SELECT CompanyName, CategoryName, ilosc FROM t
WHERE rank = 1



-- 2023
-- podaj listę dzieci które oddały książkę o nazwie (jakąś nazwa) w dniu ( jakąś pełna data)
SELECT m.firstname, m.lastname FROM member m
JOIN juvenile j ON j.member_no = m.member_no
WHERE m.member_no IN (
    SELECT lh.member_no FROM loanhist lh
    JOIN title t ON t.title_no = lh.member_no
    WHERE t.title = 'Emma' AND in_date >= '1999.10.29' AND in_date < '2005.10.30'
)

-- Podaj łączna liczbę i wartość obsłużonych zamówień wszystkich pracowników w lutym 1997 (pamiętaj o opłacie za przesyłkę) , 
-- wyświetl także pracowników którzy nie mają żadnych zamówień
SELECT e.FirstName, e.LastName, (
    SELECT COUNT(*) FROM Orders o
    WHERE o.EmployeeID = e.EmployeeID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2 
) ilosc, ISNULL((
    SELECT SUM(od.Quantity*od.Quantity*(1-od.Discount)) FROM Orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    WHERE e.EmployeeID = o.EmployeeID  AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2 
),0) + ISNULL((
    SELECT SUM(o.Freight) FROM Orders o
    WHERE e.EmployeeID = o.EmployeeID  AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2 
),0) suma FROM Employees e

-- Podaj kategorie która w (jakiś rok) zrobiła największy przychód, zrób dla niej podział na miesiące (czyli kategoria, miesiąc, przychód w tym miesiącu)
;WITH t as(
    SELECT TOP 1 c.CategoryName FROM Categories c
    JOIN Products p ON p.CategoryID = c.CategoryID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
    JOIN Orders o ON o.OrderID = od.OrderID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY c.CategoryName
    ORDER BY SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) DESC
)
SELECT c.CategoryName, MONTH(o.OrderDate) as month, SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) suma FROM Categories c
JOIN Products p ON p.CategoryID = c.CategoryID
LEFT OUTER JOIN [Order Details] od ON od.ProductID = p.ProductID
LEFT OUTER JOIN Orders o ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = 1997 AND c.CategoryName IN (
    SELECT * FROM t
)
GROUP BY c.CategoryName, MONTH(o.OrderDate) with ROLLUP


-- ZAD 1, niezerowy zysk z produktu w 1996, nazwa produktu
SELECT p.ProductName, SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM Products p
LEFT OUTER JOIN [Order Details] od ON od.ProductID = p.ProductID
LEFT OUTER JOIN Orders o ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = 1996
GROUP BY p.ProductName
HAVING SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) > 0


-- - ZAD 2, tytuły ksiazek poozyczoneprzez wiecej niz 1 czytelnika, imiona i nazwiska, tacy ktorzy mają dzieci
;WITH t AS (
    SELECT m.member_no FROM member m 
    JOIN adult a ON a.member_no = m.member_no
    WHERE m.member_no IN (
        SELECT adult_member_no FROM juvenile
    )
)
SELECT DISTINCT t.title, COUNT(DISTINCT lh.member_no) FROM (
    SELECT * FROM loanhist lh
    WHERE lh.member_no in (SELECT * FROM t)
) as lh
LEFT OUTER JOIN title t ON lh.title_no = t.title_no
GROUP BY t.title
HAVING COUNT(DISTINCT lh.member_no) > 1


-- ZAD 3, podaj wszystkie zamówienia dla których opłata za przesyłke > od sredniej w danym roku
SELECT o.OrderID FROM Orders o
WHERE o.Freight > (
    SELECT AVG(o2.Freight) FROM Orders o2
    WHERE YEAR(o2.OrderDate) = YEAR(o.OrderDate)
)


/* Podaj liczbę̨ zamówień oraz wartość zamówień (uwzględnij opłatę za przesyłkę)
obsłużonych przez każdego pracownika w lutym 1997. Za datę obsłużenia
zamówienia należy uznać datę jego złożenia (orderdate). Jeśli pracownik nie
obsłużył w tym okresie żadnego zamówienia, to też powinien pojawić się na liście
(liczba obsłużonych zamówień oraz ich wartość jest w takim przypadku równa 0).
Zbiór wynikowy powinien zawierać: imię i nazwisko pracownika, liczbę obsłużonych
zamówień, wartość obsłużonych zamówień. (baza northwind) */
SELECT e.FirstName +' '+ e.LastName, (
    SELECT COUNT(*) FROM Orders o
    WHERE e.EmployeeID = o.EmployeeID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2
) ile, ISNULL((
    SELECT SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) FROM Orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    WHERE e.EmployeeID = o.EmployeeID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2
),0) + ISNULL((
    SELECT SUM(o.Freight) FROM Orders o
    WHERE e.EmployeeID = o.EmployeeID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2
),0) FROM Employees e





;WITH t AS(
    SELECT e.EmployeeID, c.CompanyName, COUNT(*) as ilosc, ROW_NUMBER() OVER (PARTITION BY e.EmployeeID ORDER BY COUNT(*) DESC) rank FROM Orders o
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY e.EmployeeID, c.CompanyName
)
SELECT e.FirstName+' '+e.LastName, t.CompanyName, t.ilosc FROM Employees e 
LEFT OUTER JOIN t ON  e.EmployeeID = t.EmployeeID
WHERE t.rank = 1 


-- Podaj nazwy produktów które w marcu 1997 nie były kupowane przez klientów z
-- Francji. Dla każdego takiego produktu podaj jego nazwę, nazwę kategorii do której
-- należy ten produkt oraz jego cenę.
SELECT p.ProductName, c.CategoryName, s.CompanyName FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
JOIN Suppliers s ON s.SupplierID = p.SupplierID
WHERE p.ProductID NOT IN (
    SELECT od.ProductID FROM [Order Details] od
    JOIN Orders o ON o.OrderID = od.OrderID
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3
)

-- 1) Dla każdego pracownika, który ma podwładnego podaj wartość obsłużonych przez niego przesyłek w grudniu 1997. Uwzględnij rabat i opłatę za przesyłkę.
SELECT e.FirstName, e.LastName, (
    SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM Orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    WHERE o.EmployeeID = e.EmployeeID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 12
) + (
    SELECT SUM(o.Freight) FROM Orders o
    WHERE o.EmployeeID = e.EmployeeID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 12
) FROM Employees e
WHERE e.EmployeeID IN (
    SELECT DISTINCT e.EmployeeID FROM Employees e
    LEFT OUTER JOIN Employees ep ON ep.ReportsTo = e.EmployeeID
    WHERE ep.EmployeeID IS NOT NULL
)



-- 2) Podaj listę wszystkich dorosłych, którzy mieszkają w Arizonie i mają dwójkę dzieci zapisanych do biblioteki oraz listę dorosłych, mieszkających w Kalifornii 
-- i mają 3 dzieci. Dla każdej z tych osób podaj liczbę książek przeczytanych w grudniu 2001 przez tę osobę i jej dzieci. (Arizona - 'AZ', Kalifornia - 'CA'
SELECT m.firstname, m.lastname, (
    SELECT COUNT(*) FROM loanhist lh
    WHERE YEAR(out_date) = 2001 AND MONTH(out_date) = 12 AND m.member_no = lh.member_no 
) + (
    SELECT COUNT(*) FROM loanhist lh
    WHERE YEAR(out_date) = 2001 AND MONTH(out_date) = 12 AND j.adult_member_no = lh.member_no 
) FROM member m
JOIN adult a ON a.member_no = m.member_no
JOIN juvenile j ON j.adult_member_no = m.member_no
WHERE ((
    SELECT COUNT(*) FROM juvenile
    WHERE juvenile.adult_member_no = m.member_no
) = 2 AND a.[state] = 'AZ') 
OR
((
    SELECT COUNT(*) FROM juvenile
    WHERE juvenile.adult_member_no = m.member_no
) = 3 AND a.[state] = 'CA') 



-- 4) Podaj nazwy produktów, które nie były sprzedawane w marcu 1997.
SELECT p.ProductName FROM Products p
WHERE p.ProductID NOT IN (
    SELECT od.ProductID FROM [Order Details] od
    JOIN Orders o ON o.OrderID = od.OrderID
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3 
)


-- 3) Podaj klientów, którzy nie złożyli zamówień w 1997. 3 wersje: join, in, exists.
SELECT c.CompanyName FROM Customers c
WHERE c.CustomerID NOT IN (
    SELECT o.CustomerID FROM Orders o
    WHERE YEAR(o.OrderDate) = 1997
)

SELECT c.CompanyName FROM Customers c
WHERE NOT EXISTS (
    SELECT o.CustomerID FROM Orders o
    WHERE YEAR(o.OrderDate) = 1997 AND o.CustomerID = c.CustomerID
)

SELECT c.CompanyName, o.OrderDate FROM Customers c 
LEFT JOIN Orders o ON o.CustomerID = c.CustomerID AND YEAR(o.OrderDate) = 1997
WHERE o.OrderDate IS NULL 

SELECT c.CategoryName, MONTH(o.OrderDate) as 'Month', YEAR(o.OrderDate) as 'Year', SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) as Value
	FROM Categories as c JOIN Products as p ON c.CategoryID = p.CategoryID 
	JOIN [Order Details] as od ON od.ProductID = p.ProductID
	JOIN Orders as o ON o.OrderID = od.OrderID 
	WHERE YEAR(o.OrderDate) = '1996' OR YEAR(o.OrderDate) = '1997'
	GROUP BY c.CategoryName, YEAR(o.OrderDate), MONTH(o.OrderDate)
	ORDER BY c.CategoryName



-- Dla każdego klienta podaj imię i nazwisko pracownika, który w 1997r obsłużył
-- najwięcej jego zamówień, podaj także liczbę tych zamówień (jeśli jest kilku takich
-- pracownikow to wystarczy podać imię nazwisko jednego nich). Zbiór wynikowy
-- powinien zawierać nazwę klienta, imię i nazwisko pracownika oraz liczbę
-- obsłużonych zamówień. (baza northwind)
;WITH t as (
    SELECT c.CustomerID, e.FirstName, e.LastName, COUNT(*) as ilosc, ROW_NUMBER() OVER (PARTITION BY c.CustomerID ORDER BY COUNT(*) DESC) as rank FROM Orders o
    JOIN Customers c ON c.CustomerID = o.CustomerID 
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY c.CustomerID, e.FirstName, e.LastName
)
SELECT c.CompanyName, FirstName+' '+LastName as emloyee, ilosc FROM Customers c
LEFT OUTER JOIN t ON t.CustomerID = c.CustomerID
WHERE rank = 1 OR rank IS NULL

-- Napisz polecenie które wyświetla imiona i nazwiska dorosłych członków biblioteki,
-- mieszkających w Arizonie (AZ) lub Kalifornii (CA), których wszystkie dzieci są
-- urodzone przed '2000-10-14'
SELECT m.firstname, m.lastname FROM member m
JOIN adult a ON a.member_no = m.member_no
WHERE (a.[state] = 'AZ' OR a.[state] = 'CA') AND m.member_no NOT IN (
    SELECT adult_member_no FROM juvenile
    WHERE birth_date >= '2000.10.14' 
) AND m.member_no IN (
    SELECT adult_member_no FROM juvenile
)

-- Dla każdego produktu z kategorii 'confections' podaj wartość przychodu za ten
-- produkt w marcu 1997 (wartość sprzedaży tego produktu bez opłaty za przesyłkę).
-- Jeśli dany produkt (należący do kategorii 'confections') nie był sprzedawany w tym
-- okresie to też powinien pojawić się na liście (wartość sprzedaży w takim przypadku
-- jest równa 0) (baza northwind)
SELECT p.ProductName, ISNULL((
    SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM [Order Details] od
    JOIN Orders o ON od.OrderID = o.OrderID
    WHERE od.ProductID = p.ProductID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3
),0) FROM Products p 
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE c.CategoryName = 'Confections'


-- Podaj tytuły książek, które nie są aktualnie zarezerwowane przez dzieci mieszkające
-- w Arizonie (AZ). (baza library)
SELECT t.title FROM title t
WHERE t.title_no NOT IN (
    SELECT t2.title_no FROM title t2
    LEFT OUTER JOIN item i ON i.title_no = t2.title_no
    LEFT OUTER JOIN reservation r ON r.isbn = i.isbn
    LEFT OUTER JOIN member m ON m.member_no = r.member_no
    JOIN juvenile j ON j.member_no = m.member_no
    JOIN adult a ON a.member_no = j.adult_member_no
    WHERE a.[state] = 'AZ'
) 

-- Dla każdego przewoźnika podaj nazwę produktu z kategorii 'Seafood', który ten
-- przewoźnik przewoził najczęściej w kwietniu 1997. Podaj też informację ile razy
-- dany przewoźnik przewoził ten produkt w tym okresie (jeśli takich produktów jest
-- więcej to wystarczy podać nazwę jednego z nich). Zbiór wynikowy powinien
-- zawierać nazwę przewoźnika, nazwę produktu oraz informację ile razy dany produkt
-- był przewożony (baza northwind)
;WITH t AS(
    SELECT s.CompanyName, p.ProductName, COUNT(*) ilosc, ROW_NUMBER() OVER (PARTITION BY s.CompanyName ORDER BY COUNT(*) DESC) as rank FROM Orders o 
    JOIN Shippers s ON s.ShipperID = o.ShipVia
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products p ON p.ProductID = od.ProductID
    JOIN Categories c ON c.CategoryID = p.CategoryID
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 4 AND c.CategoryName = 'Seafood'
    GROUP BY s.CompanyName, p.ProductName
)
SELECT s.CompanyName, ProductName, ilosc FROM Shippers s
LEFT OUTER JOIN t ON t.CompanyName = s.CompanyName
WHERE rank = 1 OR ilosc IS NULL

-- Pokaż nazwy produktów, kategorii 'Beverages' które nie były kupowane w okresie
-- od '1997.02.20' do '1997.02.25' Dla każdego takiego produktu podaj jego nazwę,
-- nazwę dostawcy (supplier), oraz nazwę kategorii. Zbiór wynikowy powinien
-- zawierać nazwę produktu, nazwę dostawcy oraz nazwę kategorii. (baza northwind)
SELECT p.ProductName, s.CompanyName, c.CategoryName FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
JOIN Suppliers s ON s.SupplierID = p.SupplierID
WHERE c.CategoryName = 'Beverages' AND p.ProductID NOT IN (
    SELECT od.ProductID FROM [Order Details] od 
    JOIN Orders o ON o.OrderID = od.OrderID
    WHERE o.OrderDate >= '1997.02.20' AND o.OrderDate < '1997.02.25'
)

-- Podaj listę dzieci będących członkami biblioteki, które w dniu '2001-12-14' nie
-- zwróciły do biblioteki książki o tytule 'Walking'. Zbiór wynikowy powinien zawierać
-- imię i nazwisko oraz dane adresowe dziecka. (baza library)
SELECT m.firstname, m.lastname, a.street+' '+a.city+' '+a.[state]+' '+a.zip as adres FROM member m
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
WHERE m.member_no IN (
    SELECT lh.member_no FROM loanhist lh
    LEFT OUTER JOIN title t ON t.title_no = lh.title_no
    WHERE lh.in_date >= '2001-12-14' AND lh.in_date < '2001-12-15' AND title = 'Walking'
)

-- Podaj liczbę̨
--  zamówień oraz wartość zamówień (bez opłaty za przesyłkę)
-- obsłużonych przez każdego pracownika w marcu 1997. Za datę obsłużenia
-- zamówienia należy uznać datę jego złożenia (orderdate). Jeśli pracownik nie
-- obsłużył w tym okresie żadnego zamówienia, to też powinien pojawić się na liście
-- (liczba obsłużonych zamówień oraz ich wartość jest w takim przypadku równa 0).
-- Zbiór wynikowy powinien zawierać: imię i nazwisko pracownika, liczbę obsłużonych
-- zamówień, wartość obsłużonych zamówień, oraz datę najpóźniejszego zamówienia
-- (w badanym okresie). (baza northwind)
SELECT e.FirstName+' '+e.LastName as name, (
    SELECT COUNT(*) FROM Orders o
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3 AND o.EmployeeID = e.EmployeeID
) ilosc, ISNULL((
    SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM Orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3 AND o.EmployeeID = e.EmployeeID
),0) sume, (
    SELECT MAX(o.OrderDate) FROM Orders o
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3 AND o.EmployeeID = e.EmployeeID
) ostatnie FROM Employees e 


-- Podaj nazwy produktów które w marcu 1997 nie były kupowane przez klientów z
-- Francji. Dla każdego takiego produktu podaj jego nazwę, nazwę kategorii do której
-- należy ten produkt oraz jego cenę.
SELECT p.ProductName, p.UnitPrice, c.CategoryName FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE p.ProductID NOT IN (
    SELECT od.ProductID FROM [Order Details] od
    JOIN Orders o ON o.OrderID = od.OrderID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE c.Country = 'France' AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3
)

-- ZAD 3, podaj wszystkie zamówienia dla których opłata za przesyłke > od sredniej w danym roku
SELECT o.OrderID FROM Orders o 
WHERE o.Freight > (
    SELECT AVG(o2.Freight) FROM Orders o2
    WHERE YEAR(o2.OrderDate) = YEAR(o.OrderDate)
)

-- ZAD 1, niezerowy zysk z produktu w 1996, nazwa produktu
SELECT p.ProductName, ISNULL((
    SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM [Order Details] od 
    JOIN Orders o ON o.OrderID = od.OrderID
    WHERE YEAR(o.OrderDate) = 1996 AND p.ProductID = od.ProductID
),0) zysk FROM Products p
WHERE (
    SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM [Order Details] od 
    JOIN Orders o ON o.OrderID = od.OrderID
    WHERE YEAR(o.OrderDate) = 1996 AND p.ProductID = od.ProductID
) is not null


-- Podaj kategorie która w (jakiś rok) zrobiła największy przychód, zrób dla niej podział na miesiące (czyli kategoria, miesiąc, przychód w tym miesiącu)
;WITH t AS(
    SELECT TOP 1 c.CategoryID FROM Categories c
    ORDER BY (
        SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM Products p
        JOIN [Order Details] od ON od.ProductID = p.ProductID
        JOIN Orders o ON o.OrderID = od.OrderID AND YEAR(o.OrderDate) = 1997
        WHERE c.CategoryID = p.CategoryID 
    ) DESC
) 
SELECT c.CategoryName, MONTH(o.orderdate) month, SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM Categories c
JOIN Products p ON p.CategoryID = c.CategoryID
JOIN [Order Details] od ON od.ProductID = p.ProductID
JOIN Orders o ON o.OrderID = od.OrderID AND YEAR(o.OrderDate) = 1997
WHERE c.CategoryID IN (SELECT * FROM t)
GROUP BY c.CategoryName, MONTH(o.OrderDate)

-- ZAD 1, niezerowy zysk z produktu w 1996, nazwa produktu
SELECT p.ProductName, SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM Products p
LEFT OUTER JOIN [Order Details] od ON od.ProductID = p.ProductID
LEFT OUTER JOIN Orders o ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = 1996 
GROUP BY p.ProductName

-- Podaj tytuły książek wypożyczonych (aktualnie) przez dzieci mieszkające w Arizonie
-- (AZ). Zbiór wynikowy powinien zawierać imię i nazwisko członka biblioteki
-- (dziecka), jego adres oraz tytuł wypożyczonej książki. Jeśli jakieś dziecko
-- mieszkająca w Arizonie nie ma wypożyczonej żadnej książki to też powinno znaleźć
-- się na liście, a w polu przeznaczonym na tytuł książki powinien pojawić się napis
-- BRAK. (baza library)
SELECT m.firstname, m.lastname, a.street+' '+a.city+' '+a.[state]+' '+a.zip, ISNULL(t.title,'BRAK') FROM member m
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
LEFT OUTER JOIN loan l ON l.member_no = m.member_no
LEFT OUTER JOIN title t ON t.title_no = l.title_no
WHERE a.[state] = 'AZ' 


-- Napisz polecenie które wyświetla imiona i nazwiska dorosłych członków biblioteki,
-- mieszkających w Arizonie (AZ) lub Kalifornii (CA), których wszystkie dzieci są
-- urodzone przed '2000-10-14'
SELECT m.firstname, m.lastname FROM member m
JOIN adult a ON a.member_no = m.member_no
WHERE (a.[state] = 'AZ' OR a.[state] = 'CA') AND m.member_no NOT IN(
    SELECT adult_member_no FROM juvenile
    WHERE birth_date >= '2000-10-14' 
) AND  m.member_no IN(
    SELECT adult_member_no FROM juvenile
)

-- Dla każdego klienta podaj imię i nazwisko pracownika, który w 1997r obsłużył
-- najwięcej jego zamówień, podaj także liczbę tych zamówień (jeśli jest kilku takich
-- pracownikow to wystarczy podać imię nazwisko jednego nich). Zbiór wynikowy
-- powinien zawierać nazwę klienta, imię i nazwisko pracownika oraz liczbę
-- obsłużonych zamówień. (baza northwind)
;WITH t AS(
    SELECT c.CompanyName, e.FirstName+' '+e.LastName emloyee, COUNT(*) ilosc, ROW_NUMBER() OVER (PARTITION BY c.companyname ORDER BY COUNT(*) DESC) rank FROM Orders o
    JOIN Customers c ON c.CustomerID = o.CustomerID
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY c.CompanyName, e.FirstName, e.LastName
)
SELECT CompanyName,emloyee,ilosc FROM t
WHERE rank = 1 

SELECT c.CompanyName, ISNULL((
    SELECT MAX(wartosc) FROM (
        SELECT o.OrderID, o.CustomerID ,(
            SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM [Order Details] od 
            WHERE od.OrderID = o.OrderID
        ) wartosc FROM Orders o
    ) as t
    WHERE t.CustomerID = c.CustomerID
),0) FROM Customers c


-- Dla każdego przewoźnika podaj nazwę produktu z kategorii 'Seafood', który ten
-- przewoźnik przewoził najczęściej w kwietniu 1997. Podaj też informację ile razy
-- dany przewoźnik przewoził ten produkt w tym okresie (jeśli takich produktów jest
-- więcej to wystarczy podać nazwę jednego z nich). Zbiór wynikowy powinien
-- zawierać nazwę przewoźnika, nazwę produktu oraz informację ile razy dany produkt
-- był przewożony (baza northwind)
;WITH t AS (
    SELECT s.CompanyName, p.ProductName, COUNT(*) ilosc, ROW_NUMBER() OVER (PARTITION BY s.companyname ORDER BY COUNT(*) DESC) rank FROM Orders o 
    JOIN Shippers s ON s.ShipperID = o.ShipVia
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products p ON p.ProductID = od.ProductID
    JOIN Categories c ON c.CategoryID = p.CategoryID
    WHERE c.CategoryName = 'Seafood'
    GROUP BY s.CompanyName, p.ProductName
)
SELECT CompanyName, ProductName, ilosc FROM t
WHERE rank = 1 


-- Podaj nazwy produktów które w marcu 1997 nie były kupowane przez klientów z
-- Francji. Dla każdego takiego produktu podaj jego nazwę, nazwę kategorii do której
-- należy ten produkt oraz jego cenę.
SELECT p.ProductName, c.CategoryName FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE p.ProductID NOT IN (
    SELECT od.ProductID FROM [Order Details] od
    JOIN Orders o ON o.OrderID = od.OrderID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3 AND c.Country = 'France'
)


-- Napisz polecenie które wyświetla imiona i nazwiska dorosłych członków biblioteki,
-- mieszkających w Arizonie (AZ) lub Kalifornii (CA), których wszystkie dzieci są
-- urodzone przed '2000-10-14'
SELECT m.firstname, m.lastname FROM member m
JOIN adult a ON a.member_no = m.member_no
WHERE (a.[state] = 'AZ' OR a.[state] = 'CA') AND m.member_no NOT IN(
    SELECT adult_member_no FROM juvenile
    WHERE birth_date >= '2000.10.14' 
) AND m.member_no IN (
    SELECT adult_member_no FROM juvenile
)

-- Dla każdego klienta podaj imię i nazwisko pracownika, który w 1997r obsłużył
-- najwięcej jego zamówień, podaj także liczbę tych zamówień (jeśli jest kilku takich
-- pracownikow to wystarczy podać imię nazwisko jednego nich). Zbiór wynikowy
-- powinien zawierać nazwę klienta, imię i nazwisko pracownika oraz liczbę
-- obsłużonych zamówień. (baza northwind)
;WITH t AS (
    SELECT c.CompanyName, e.FirstName, e.LastName, COUNT(*) ilosc, ROW_NUMBER() OVER (PARTITION BY c.companyname ORDER BY COUNT(*) DESC) as rank FROM Orders o
    JOIN Customers c ON c.CustomerID = o.CustomerID
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY c.CompanyName, e.FirstName, e.LastName
)
SELECT * FROM t
WHERE rank = 1

-- Dla każdego produktu z kategorii 'confections' podaj wartość przychodu za ten
-- produkt w marcu 1997 (wartość sprzedaży tego produktu bez opłaty za przesyłkę).
-- Jeśli dany produkt (należący do kategorii 'confections') nie był sprzedawany w tym
-- okresie to też powinien pojawić się na liście (wartość sprzedaży w takim przypadku
-- jest równa 0) (baza northwind)
SELECT p.ProductName, ISNULL((
    SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM [Order Details] od
    JOIN Orders o ON o.OrderID = od.OrderID
    WHERE YEAR(o.OrderDate) = 1997 AND  MONTH(o.OrderDate) = 3 AND od.ProductID = p.ProductID
),0) FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE c.CategoryName = 'confections'


-- Podaj tytuły książek, które nie są aktualnie zarezerwowane przez dzieci mieszkające
-- w Arizonie (AZ). (baza library)
SELECT t.title FROM title t 
WHERE t.title_no NOT IN (
    SELECT i.title_no FROM item i
    JOIN reservation r ON r.isbn = i.isbn
    JOIN member m ON m.member_no = r.member_no
    JOIN juvenile j ON j.member_no = m.member_no
    JOIN adult a ON a.member_no = j.adult_member_no
    WHERE a.[state] = 'AZ'
)

-- Podaj liczbę̨
--  zamówień oraz wartość zamówień (bez opłaty za przesyłkę)
-- obsłużonych przez każdego pracownika w marcu 1997. Za datę obsłużenia
-- zamówienia należy uznać datę jego złożenia (orderdate). Jeśli pracownik nie
-- obsłużył w tym okresie żadnego zamówienia, to też powinien pojawić się na liście
-- (liczba obsłużonych zamówień oraz ich wartość jest w takim przypadku równa 0).
-- Zbiór wynikowy powinien zawierać: imię i nazwisko pracownika, liczbę obsłużonych
-- zamówień, wartość obsłużonych zamówień, oraz datę najpóźniejszego zamówienia
-- (w badanym okresie). (baza northwind)
SELECT e.FirstName, e.LastName, (
    SELECT COUNT(*) FROM Orders
    WHERE Orders.EmployeeID = e.EmployeeID AND YEAR(OrderDate) = 1997 AND MONTH(OrderDate) = 3
) ilosc, ISNULL(( 
    SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM Orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    WHERE o.EmployeeID = e.EmployeeID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3
),0) suma, (
    SELECT MAX(o.OrderDate) FROM Orders o
    WHERE o.EmployeeID = e.EmployeeID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3
) data FROM Employees e

-- Podaj listę dzieci będących członkami biblioteki, które w dniu '2001-12-14'
-- zwróciły do biblioteki książkę o tytule 'Walking'. Zbiór wynikowy powinien zawierać
-- imię i nazwisko oraz dane adresowe dziecka. (baza library)
SELECT m.firstname, m.lastname FROM member m
JOIN juvenile j ON j.member_no = m.member_no
WHERE m.member_no IN (
    SELECT member_no FROM loanhist
    JOIN title t ON t.title_no = loanhist.title_no
    WHERE t.title = 'Walking' AND in_date >= '2001.12.14' AND in_date < '2001.12.15'
)

