-- Podaj liczbę̨
--  zamówień oraz wartość zamówień (uwzględnij opłatę za przesyłkę)
-- obsłużonych przez każdego pracownika w lutym 1997. Za datę obsłużenia
-- zamówienia należy uznać datę jego złożenia (orderdate). Jeśli pracownik nie
-- obsłużył w tym okresie żadnego zamówienia, to też powinien pojawić się na liście
-- (liczba obsłużonych zamówień oraz ich wartość jest w takim przypadku równa 0).
-- Zbiór wynikowy powinien zawierać: imię i nazwisko pracownika, liczbę obsłużonych
-- zamówień, wartość obsłużonych zamówień. (baza northwind)


SELECT e.FirstName, e.LastName, ISNULL((
    SELECT COUNT(*) as quantity FROM orders o1
    JOIN [Order Details] od ON o1.OrderID = od.OrderID
    WHERE YEAR(o1.OrderDate) = 1997 and MONTH(o1.OrderDate) = 2 AND o1.EmployeeID = e.EmployeeID), 0
)as quantity, ISNULL((
    SELECT sum(UnitPrice*Quantity*(1-Discount)) as value FROM orders o1
    JOIN [Order Details] od ON o1.OrderID = od.OrderID
    WHERE YEAR(o1.OrderDate) = 1997 and MONTH(o1.OrderDate) = 2 AND o1.EmployeeID = e.EmployeeID
),0) + ISNULL((
    SELECT sum(o2.Freight) as value FROM orders o2
    WHERE YEAR(o2.OrderDate) = 1997 and MONTH(o2.OrderDate) = 2 AND o2.EmployeeID = e.EmployeeID
),0) as value
FROM employees e


-- Podaj listę dzieci będących członkami biblioteki, które w dniu '2001-12-14' nie
-- zwróciły do biblioteki książki o tytule 'Walking'. Zbiór wynikowy powinien zawierać
-- imię i nazwisko oraz dane adresowe dziecka. (baza library)
SELECT m.firstname, m.lastname, CONCAT(a.city,' ',a.[state],' ',a.street,' ',a.zip) adress  FROM juvenile j 
JOIN member m ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
wheRE m.member_no NOT IN (
    SELECT m.member_no  FROM juvenile j 
    JOIN member m ON j.member_no = m.member_no
    JOIN adult a ON a.member_no = j.adult_member_no
    JOIN loan l on l.member_no = m.member_no
    JOIN copy c on c.copy_no = l.copy_no
    JOIN loanhist lh on lh.copy_no = c.copy_no
    join title t on t.title_no = l.title_no
    WHERE CAST(lh.in_date as Date) = '2001-12-14' and title LIKE 'Walking'
)


-- Dla każdego klienta podaj imię i nazwisko pracownika, który w 1997r obsłużył
-- najwięcej jego zamówień, podaj także liczbę tych zamówień (jeśli jest kilku takich
-- pracownikow to wystarczy podać imię nazwisko jednego nich). Za datę obsłużenia
-- zamówienia należy przyjąć orderdate. Zbiór wynikowy powinien zawierać nazwę
-- klienta, imię i nazwisko pracownika oraz liczbę obsłużonych zamówień. (baza
-- northwind)
;WITH t as (
    SELECT e.FirstName, e.LastName, c.CompanyName, COUNT(*) as ilosc, ROW_NUMBER() OVER (PARTITION BY e.FirstName, e.LastName ORDER BY COUNT(*) DESC) as rank FROM Orders o
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY e.FirstName, e.LastName, c.CompanyName
)
SELECT FirstName+' '+LastName as emloyee, CompanyName, ilosc FROM t 
WHERE rank = 1 



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
    SELECT COUNT(*) FROM orders o
    WHERE YEAR(o.OrderDate) = 1997 and MONTH(O.OrderDate) = 3 AND o.EmployeeID = e.EmployeeID
) as quantity, (
    SELECT SUM(od.Quantity * od.UnitPrice * (1-od.Discount)) FROM orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    WHERE YEAR(o.OrderDate) = 1997 and MONTH(O.OrderDate) = 3 AND o.EmployeeID = e.EmployeeID
 ) as orders_sum, (
    SELECT MAX(o.OrderDate) FROM orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    WHERE YEAR(o.OrderDate) = 1997 and MONTH(O.OrderDate) = 3 AND o.EmployeeID = e.EmployeeID
 ) as the_most_valuable FROM Employees e


-- Podaj listę dzieci będących członkami biblioteki, które w dniu '2001-12-14' nie
-- zwróciły do biblioteki książki o tytule 'Walking'. Zbiór wynikowy powinien zawierać
-- imię i nazwisko oraz dane adresowe dziecka. (baza library)
SELECT m.firstname, m.lastname, a.street FROM member m
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
WHERE m.member_no NOT IN (
    SELECT m.member_no FROM member m 
    LEFT JOIN loan l ON l.member_no = m.member_no
    LEFT JOIN copy c ON c.copy_no = l.copy_no
    LEFT JOIN loanhist lh ON lh.isbn = c.isbn
    LEFT JOIN title t ON t.title_no = l.title_no
    WHERE CAST(lh.in_date as Date) = '2001-12-14' AND t.title = 'Walking'
)


-- Podaj tytuły książek zarezerwowanych przez dorosłych członków biblioteki
-- mieszkających w Arizonie (AZ). Zbiór wynikowy powinien zawierać imię i nazwisko
-- członka biblioteki, jego adres oraz tytuł zarezerwowanej książki. Jeśli jakaś osoba
-- dorosła mieszkająca w Arizonie nie ma zarezerwowanej żadnej książki to też
-- powinna znaleźć się na liście, a w polu przeznaczonym na tytuł książki powinien
-- pojawić się napis BRAK. (baza library)
SELECT m.firstname, m.lastname, CONCAT(a.city,' ',a.[state],' ',a.street,' ',a.zip) as adress, ISNULL((
    SELECT STRING_AGG(t.title, ', ') FROM reservation r
    LEFT OUTER JOIN item i ON i.isbn = r.isbn
    LEFT OUTER JOIN title t ON t.title_no = i.title_no
    WHERE r.member_no = m.member_no
),'BRAK') FROM member m
JOIN adult a ON a.member_no = m.member_no
WHERE a.[state] = 'AZ'



-- Pokaż nazwy produktów, kategorii 'Beverages' które nie były kupowane w okresie
-- od '1997.02.20' do '1997.02.25' Dla każdego takiego produktu podaj jego nazwę,
-- nazwę dostawcy (supplier), oraz nazwę kategorii. Zbiór wynikowy powinien
-- zawierać nazwę produktu, nazwę dostawcy oraz nazwę kategorii. (baza northwind)
SELECT p.ProductName, s.CompanyName, c.CategoryName FROM Products p
JOIN Suppliers s ON s.SupplierID = p.SupplierID
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE c.CategoryName = 'Beverages' and p.ProductID NOT IN (
    SELECT OD.ProductID FROM [Order Details] od
    JOIN Orders o ON o.OrderID = od.OrderID
    WHERE o.OrderDate >= '1997-02-20' AND o.OrderDate < '1997-02-25'
)

-- Dla każdego pracownika podaj nazwę klienta, dla którego dany pracownik w 1997r
-- obsłużył najwięcej zamówień, podaj także liczbę tych zamówień (jeśli jest kilku
-- takich klientów to wystarczy podać nazwę jednego nich). Za datę obsłużenia
-- zamówienia należy przyjąć orderdate. Zbiór wynikowy powinien zawierać imię i
-- nazwisko pracownika, nazwę klienta, oraz liczbę obsłużonych zamówień. (baza
-- northwind)
;WITH t as (
    SELECT e.FirstName, e.LastName, c.CompanyName, COUNT(*) as ilosc, ROW_NUMBER() OVER (PARTITION BY e.FirstName, e.LastName ORDER BY COUNT(*) DESC) as rank FROM Orders o
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY e.FirstName, e.LastName, c.CompanyName
)
SELECT FirstName+' '+LastName as emloyee, CompanyName, ilosc FROM t 
WHERE rank = 1 


-- Podaj nazwy produktów które w marcu 1997 nie były kupowane przez klientów z
-- Francji. Dla każdego takiego produktu podaj jego nazwę, nazwę kategorii do której
-- należy ten produkt oraz jego cenę.
SELECT p.ProductName, c.CategoryName, p.UnitPrice FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE p.ProductID NOT IN (
    SELECT p.ProductID FROM Products p
    JOIN [Order Details] od ON od.ProductID = p.ProductID
    JOIN Orders o ON o.OrderID = od.OrderID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3 AND c.Country = 'France'
)

-- Napisz polecenie które wyświetla imiona i nazwiska dorosłych członków biblioteki,
-- mieszkających w Arizonie (AZ) lub Kalifornii (CA), których wszystkie dzieci są
-- urodzone przed '2000-10-14'
SELECT m.firstname, m.lastname 
FROM adult a
JOIN member m ON a.member_no = m.member_no
WHERE (a.[state] = 'AZ' OR a.[state] = 'CA') and NOT EXISTS (
    SELECT 1
    FROM juvenile j
    WHERE j.adult_member_no = a.member_no 
      AND j.birth_date < '2000-10-14'
)




-- Zad.1. Wyświetl produkt, który przyniósł najmniejszy, ale niezerowy, przychód w 1996 roku
SELECT TOP 1 t.ProductName FROM (
    SELECT p.ProductName, SUM(od.Quantity * od.UnitPrice * (1-od.Discount)) as suma FROM Products p 
    JOIN [Order Details] od ON od.ProductID = p.ProductID
    JOIN Orders o ON o.OrderID = od.OrderID AND YEAR(o.OrderDate) = 1996
    GROUP BY p.ProductName
) t
ORDER BY t.suma ASC


select top 1 P.ProductName from Products P
inner join [Order Details] od on P.ProductID = od.ProductID
inner join Orders O on O.OrderID = od.OrderID
where year(O.OrderDate) = 1996
group by P.ProductName
having sum(od.Quantity*od.UnitPrice*(1-od.Discount)) > 0
order by sum(od.Quantity*od.UnitPrice*(1-od.Discount))


-- Zad.2. Wyświetl wszystkich członków biblioteki (imię i nazwisko, adres) 
-- rozróżniając dorosłych i dzieci (dla dorosłych podaj liczbę dzieci),
-- którzy nigdy nie wypożyczyli książki
SELECT m.firstname, m.lastname, a.street, 'Adult', (
    SELECT COUNT(*) FROM juvenile j
    WHERE a.member_no = j.adult_member_no
) as childs FROM member m
inner join adult a on m.member_no = a.member_no
WHERE m.member_no NOT IN (
    SELECT lh.member_no FROM loanhist lh
) AND m.member_no NOT IN (
    SELECT l.member_no FROM loan l
)
UNION
SELECT m.firstname, m.lastname, a.street, 'Child', null as childs FROM member m
INNER JOIN juvenile j ON j.member_no = m.member_no
inner join adult a on j.adult_member_no = a.member_no
WHERE m.member_no NOT IN (
    SELECT lh.member_no FROM loanhist lh
) AND m.member_no NOT IN (
    SELECT l.member_no FROM loan l
)


select m1.firstname +' '+m1.lastname as name, a.street, 'Adult',count(j.adult_member_no) as dzieci 
	from member m1
	inner join adult a on m1.member_no = a.member_no
	left join juvenile j on a.member_no = j.adult_member_no
	where m1.member_no not in (select lh.member_no from loanhist lh)
	and m1.member_no not in (select l.member_no from loan l)
	group by m1.firstname+' '+ m1.lastname, a.street
union
select m.firstname+' '+ m.lastname as name, a2.street, 'Child', null 
	from member m
	inner join juvenile j2 on m.member_no = j2.member_no
	inner join adult a2 on j2.adult_member_no = a2.member_no
	where m.member_no not in (select lh.member_no from loanhist lh)
	and m.member_no not in (select l.member_no from loan l)
	order by 1,2


-- Zad.3. Wyświetl podsumowanie zamówień (całkowita cena + fracht) obsłużonych 
-- przez pracowników w lutym 1997 roku, uwzględnij wszystkich, nawet jeśli suma 
-- wyniosła 0.
SELECT e.FirstName, e.LastName, ISNULL((
    SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM Orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2 AND o.EmployeeID = e.EmployeeID
),0) + ISNULL((
    SELECT SUM(o.Freight) FROM Orders o
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2 AND o.EmployeeID = e.EmployeeID
),0) as suma FROM Employees e



-- 6. Wyświetl Nazwy i Numery telefonów klientów którzy zamówili produkt z kategorii "Confections"
SELECT DISTINCT c.ContactName, c.Phone FROM Customers c
JOIN orders o ON o.CustomerID = c.CustomerID
JOIN [Order Details] od ON od.OrderID = o.OrderID
JOIN Products p ON p.ProductID = od.ProductID
JOIN Categories ca ON ca.CategoryID = p.CategoryID
WHERE ca.CategoryName = 'Confections'



-- podwladni pracownicy
SELECT DISTINCT e.EmployeeID, p.EmployeeID FROM Employees e
LEFT OUTER JOIN Employees as p ON e.EmployeeID = p.ReportsTo 
WHERE p.EmployeeID IS NULL


-- 1) Dla każdego pracownika, który ma podwładnego podaj wartość obsłużonych przez niego przesyłek w grudniu 1997. Uwzględnij rabat i opłatę za przesyłkę.
SELECT e.FirstName, e.LastName, ISNULL((
    SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM Orders o
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 12 AND e.EmployeeID = o.EmployeeID 
),0) + ISNULL((
    SELECT SUM(Freight) FROM Orders o
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 12 AND e.EmployeeID = o.EmployeeID 
),0) value FROM Employees e
WHERE e.EmployeeID IN (
    SELECT DISTINCT e.EmployeeID FROM Employees e
    LEFT OUTER JOIN Employees as p ON e.EmployeeID = p.ReportsTo 
    WHERE p.EmployeeID IS NOT NULL
)

SELECT b.EmployeeID, b.LastName, b.FirstName, COUNT(e.ReportsTo) AS 'MaPodwladnych', 
	(SELECT SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) + SUM(o.Freight)
		FROM [Order Details] as od JOIN Orders AS o ON od.OrderID = o.OrderID 
		WHERE o.EmployeeID = b.EmployeeID AND YEAR(o.OrderDate) = 1997 AND MONTH(O.OrderDate) = 12) AS 'WartoscZamowien'
	 FROM Employees AS e JOIN Employees AS b ON e.ReportsTo = b.EmployeeID
	 GROUP BY b.EmployeeID, b.LastName, b.FirstName



-- ======================================================================================================================================================================================
-- Dla każdego klienta podaj imię i nazwisko pracownika, który w 1997r obsłużył
-- najwięcej jego zamówień, podaj także liczbę tych zamówień (jeśli jest kilku takich
-- pracownikow to wystarczy podać imię nazwisko jednego nich). Za datę obsłużenia
-- zamówienia należy przyjąć orderdate. Zbiór wynikowy powinien zawierać nazwę
-- klienta, imię i nazwisko pracownika oraz liczbę obsłużonych zamówień. (baza
-- northwind)
;WITH t AS (
    SELECT c.CompanyName, e.FirstName, e.LastName, COUNT(*) as total_count, ROW_NUMBER() OVER (PARTITION BY c.CompanyName ORDER BY COUNT(*) DESC) as rank FROM Orders o
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE YEAR(o.OrderDate) = 1997 
    GROUP BY c.CompanyName, e.FirstName, e.LastName
) 
SELECT CompanyName, FirstName+' '+LastName as emloyee, total_count FROM t 
WHERE rank = 1 


-- Podaj liczbę̨
--  zamówień oraz wartość zamówień (uwzględnij opłatę za przesyłkę)
-- obsłużonych przez każdego pracownika w lutym 1997. Za datę obsłużenia
-- zamówienia należy uznać datę jego złożenia (orderdate). Jeśli pracownik nie
-- obsłużył w tym okresie żadnego zamówienia, to też powinien pojawić się na liście
-- (liczba obsłużonych zamówień oraz ich wartość jest w takim przypadku równa 0).
-- Zbiór wynikowy powinien zawierać: imię i nazwisko pracownika, liczbę obsłużonych
-- zamówień, wartość obsłużonych zamówień. (baza northwind)
SELECT e.FirstName,e.LastName, ISNULL((
    SELECT SUM(od.quantity*od.UnitPrice*(1-od.Discount)) FROM Orders o
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    WHERE YEAR(o.OrderDate) = 1997 and MONTH(o.OrderDate) = 2 AND o.EmployeeID = e.EmployeeID
 )+(
    SELECT SUM(o.Freight) FROM Orders o
    WHERE YEAR(o.OrderDate) = 1997 and MONTH(o.OrderDate) = 2 AND o.EmployeeID = e.EmployeeID
 ),0) as suma, ISNULL((
    SELECT COUNT(*) FROM Orders o
    WHERE YEAR(o.OrderDate) = 1997 and MONTH(o.OrderDate) = 2 AND o.EmployeeID = e.EmployeeID
 ),0) as count FROM Employees e



-- Podaj listę dzieci będących członkami biblioteki, które w dniu '2001-12-14'
-- zwróciły do biblioteki książkę o tytule 'Walking'. Zbiór wynikowy powinien zawierać
-- imię i nazwisko oraz dane adresowe dziecka. (baza library)
SELECT m.firstname,m.lastname, a.street FROM member m
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
WHERE m.member_no IN (
    SELECT lh.member_no FROM loanhist lh
    JOIN title t ON t.title_no = lh.title_no
    WHERE lh.in_date >= '2001-12-14' and lh.in_date < '2001-12-15' and title = 'Walking'
)


-- Podaj tytuły książek zarezerwowanych przez dorosłych członków biblioteki
-- mieszkających w Arizonie (AZ). Zbiór wynikowy powinien zawierać imię i nazwisko
-- członka biblioteki, jego adres oraz tytuł zarezerwowanej książki. Jeśli jakaś osoba
-- dorosła mieszkająca w Arizonie nie ma zarezerwowanej żadnej książki to też
-- powinna znaleźć się na liście, a w polu przeznaczonym na tytuł książki powinien
-- pojawić się napis BRAK. (baza library)
SELECT m.firstname, m.lastname, a.street,ISNULL((
    SELECT STRING_AGG(t.title,', ') FROM reservation r
    JOIN item i ON i.isbn = r.isbn 
    JOIN title t ON t.title_no = i.title_no
    WHERE r.member_no = m.member_no
),'BRAK') reserwavations FROM member m 
JOIN adult a ON a.member_no = m.member_no 
WHERE a.[state] = 'AZ'


-- Pokaż nazwy produktów, kategorii 'Beverages' które nie były kupowane w okresie
-- od '1997.02.20' do '1997.02.25' Dla każdego takiego produktu podaj jego nazwę,
-- nazwę dostawcy (supplier), oraz nazwę kategorii. Zbiór wynikowy powinien
-- zawierać nazwę produktu, nazwę dostawcy oraz nazwę kategorii. (baza northwind)
SELECT p.ProductName,c.CategoryName,s.CompanyName FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
JOIN Suppliers s ON s.SupplierID = p.SupplierID
WHERE c.CategoryName = 'Beverages' and p.ProductID NOT IN (
    SELECT p2.ProductID FROM Products p2
    LEFT OUTER JOIN [Order Details] od ON od.ProductID = p2.ProductID
    JOIN Orders o ON o.OrderID = od.OrderID
    WHERE o.OrderDate >= '1997.02.20' and o.OrderDate < '1997.02.25'
)

-- Wyświetl numery zamówień złożonych w od marca do maja 1997, które były
-- przewożone przez firmę 'United Package' i nie zawierały produktów z kategorii
-- "confections". (baza northwind)
SELECT DISTINCT o.OrderID FROM Orders o
JOIN Shippers s ON s.ShipperID = o.ShipVia
WHERE s.CompanyName = 'United Package' AND o.OrderDate >= '1997-03-01' AND  o.OrderDate < '1997.05.01' AND o.OrderID NOT IN (
    SELECT DISTINCT o2.OrderID FROM Orders o2
    JOIN Shippers s ON s.ShipperID = o2.ShipVia
    LEFT OUTER JOIN [Order Details] od ON od.OrderID = o2.OrderID
    JOIN Products p ON p.ProductID = od.ProductID
    JOIN Categories c ON c.CategoryID = p.CategoryID
    WHERE s.CompanyName = 'United Package' AND o2.OrderDate >= '1997-03-01' AND  o2.OrderDate < '1997.05.01' and c.CategoryName = 'confections'
)


-- Podaj tytuły książek wypożyczonych (aktualnie) przez dzieci mieszkające w Arizonie
-- (AZ). Zbiór wynikowy powinien zawierać imię i nazwisko członka biblioteki
-- (dziecka), jego adres oraz tytuł wypożyczonej książki. Jeśli jakieś dziecko
-- mieszkająca w Arizonie nie ma wypożyczonej żadnej książki to też powinno znaleźć
-- się na liście, a w polu przeznaczonym na tytuł książki powinien pojawić się napis
-- BRAK. (baza library)
SELECT m.firstname, m.lastname, a.street, ISNULL((
    SELECT STRING_AGG(t.title,', ') FROM loan l 
    JOIN title t ON t.title_no = l.title_no
    WHERE l.member_no = m.member_no
),'BRAK') FROM member m
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON j.adult_member_no = a.member_no
WHERE a.[state] = 'AZ'


-- Podaj nazwy produktów które w marcu 1997 nie były kupowane przez klientów z
-- Francji. Dla każdego takiego produktu podaj jego nazwę, nazwę kategorii do której
-- należy ten produkt oraz jego cenę.
SELECT p.ProductName, c.CategoryName, p.UnitPrice FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE p.ProductID NOT IN (
    SELECT p2.ProductID FROM Products p2
    LEFT OUTER JOIN [Order Details] od ON od.ProductID = p2.ProductID
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
    SELECT j.adult_member_no FROM juvenile j 
    WHERE j.birth_date >= '2000-10-14'
)


-- Podaj tytuły książek, które nie są aktualnie zarezerwowane przez dzieci mieszkające
-- w Arizonie (AZ). (baza library)
SELECT title FROM title
EXCEPT
SELECT DISTINCT t.title FROM member m
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
LEFT OUTER JOIN reservation r ON r.member_no = m.member_no
LEFT OUTER JOIN item i ON i.isbn = r.isbn
JOIN title t ON t.title_no = i.title_no
WHERE a.[state] = 'AZ'


-- Dla każdego produktu z kategorii 'confections' podaj wartość przychodu za ten
-- produkt w marcu 1997 (wartość sprzedaży tego produktu bez opłaty za przesyłkę).
-- Jeśli dany produkt (należący do kategorii 'confections') nie był sprzedawany w tym
-- okresie to też powinien pojawić się na liście (wartość sprzedaży w takim przypadku
-- jest równa 0) (baza northwind)
SELECT p.ProductName, ISNULL((
    SELECT SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) FROM [Order Details] od
    JOIN Orders o ON o.OrderID = od.OrderID
    WHERE od.ProductID = p.ProductID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3
),0) as Revenue FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE CategoryName = 'confections'



-- Dla każdego przewoźnika podaj nazwę produktu z kategorii 'Seafood', który ten
-- przewoźnik przewoził najczęściej w kwietniu 1997. Podaj też informację ile razy
-- dany przewoźnik przewoził ten produkt w tym okresie (jeśli takich produktów jest
-- więcej to wystarczy podać nazwę jednego z nich). Zbiór wynikowy powinien
-- zawierać nazwę przewoźnika, nazwę produktu oraz informację ile razy dany produkt
-- był przewożony (baza northwind)
WITH MostTransported AS (
    SELECT 
        o.ShipVia AS CarrierID,
        p.ProductName,
        COUNT(*) AS TransportCount
    FROM 
        Orders o
        JOIN [Order Details] od ON o.OrderID = od.OrderID
        JOIN Products p ON od.ProductID = p.ProductID
        JOIN Categories c ON p.CategoryID = c.CategoryID
    WHERE 
        c.CategoryName = 'Seafood' AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 4
    GROUP BY 
        o.ShipVia, p.ProductName
)
SELECT 
    c.CompanyName AS CarrierName,
    m.ProductName,
    m.TransportCount
FROM 
    MostTransported m
    JOIN Shippers c ON m.CarrierID = c.ShipperID
WHERE 
    m.TransportCount = (
        SELECT MAX(TransportCount) FROM MostTransported 
        WHERE CarrierID = m.CarrierID
);


-- 1. Podaj listę dzieci będących członkami biblioteki, które w dniu '2001-12-14' nie zwróciły do biblioteki książki o
-- tytule 'Walking'. Zbiór wynikowy powinien zawierać imię i nazwisko oraz dane adresowe dziecka. (baza
-- library)
SELECT m.firstname, m.lastname FROM member m 
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
WHERE m.member_no NOT IN (
    SELECT lh.member_no FROM loanhist lh 
    JOIN title t ON t.title_no = lh.title_no
    WHERE t.title = 'Walking' AND lh.in_date >= '2001-12-14' AND lh.in_date < '2001-12-15'
)


-- Dla każdego produktu podaj wartość sprzedaży tego produktu w marcu 1997. Dodatkowo podaj ile zamówień
-- zawierało dany produkt w tym okresie. Jeśli produkt nie był zamawiany w tym okresie to też powinien pojawić
-- się na liście (wartość sprzedaży oraz liczba zamówień jest w takim przypadku równa 0). Zbiór wynikowy
-- powinien zawierać nazwę produktu, wartość sprzedaży oraz liczbę zamówień. (baza northwind)
SELECT p.ProductName, (
    SELECT COUNT(*) FROM Orders o 
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    WHERE p.ProductID = od.ProductID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3
) ilosc, ISNULL((
    SELECT sum(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM Orders o 
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    WHERE p.ProductID = od.ProductID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3
),0) suma FROM Products p 

-- 3. Podaj liczbę̨ zamówień oraz wartość zamówień (uwzględnij opłatę za przesyłkę) złożonych przez każdego
-- klienta w lutym 1997. Jeśli klient nie złożył w tym okresie żadnego zamówienia, to też powinien pojawić się na
-- liście (liczba złożonych zamówień oraz ich wartość jest w takim przypadku równa 0). Zbiór wynikowy powinien
-- zawierać: nazwę klienta, liczbę obsłużonych zamówień, oraz wartość złożonych zamówień. (baza northwind)
SELECT c.CompanyName, (
    SELECT COUNT(*) FROM Orders o
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2 AND o.CustomerID = c.CustomerID 
) ilosc, ISNULL((
    SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM Orders o
    join [Order Details] od ON od.OrderID = o.OrderID
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2 AND o.CustomerID = c.CustomerID
),0) + ISNULL((
    SELECT SUM(o.Freight) FROM Orders o
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2 AND o.CustomerID = c.CustomerID 
),0) as suma FROM Customers c


;WITH t AS (
    SELECT c.CompanyName, e.FirstName, e.LastName, COUNT(*) as ile, ROW_NUMBER() OVER (PARTITION BY c.companyname ORDER BY COUNT(*) DESC) as rank FROM orders o
    JOIN Customers c ON c.CustomerID = o.CustomerID
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2
    GROUP BY c.CompanyName, e.FirstName, e.LastName
)
SELECT CompanyName, FirstName+' '+LastName as emloyee, ile FROM t
WHERE rank = 1 
