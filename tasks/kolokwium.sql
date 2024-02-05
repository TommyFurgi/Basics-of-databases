-- PBD, 2023-12-05, godz 15.00
-- 1. Dla każdego pracownika podaj nazwę klienta, dla którego dany pracownik w 1997r obsłużył najwięcej
-- zamówień, podaj także liczbę tych zamówień (jeśli jest kilku takich klientów to wystarczy podać nazwę
-- jednego nich). Za datę obsłużenia zamówienia należy przyjąć orderdate. Zbiór wynikowy powinien zawierać
-- imię i nazwisko pracownika, nazwę klienta, oraz liczbę obsłużonych zamówień. (baza northwind)
;WITH t as (
    SELECT e.FirstName, e.LastName, c.CompanyName, COUNT(*) as ilosc, ROW_NUMBER() OVER (PARTITION BY e.FirstName, e.LastName ORDER BY COUNT(*) DESC) as rank FROM Orders o
    JOIN Employees e ON e.EmployeeID = o.EmployeeID
    JOIN Customers c ON c.CustomerID = o.CustomerID
    WHERE YEAR(o.OrderDate) = 1997
    GROUP BY e.FirstName, e.LastName, c.CompanyName
)
SELECT FirstName+' '+LastName as emloyee, CompanyName, ilosc FROM t 
WHERE rank = 1 


-- 2. Podaj tytuły książek wypożyczonych (aktualnie) przez dzieci mieszkające w Arizonie (AZ). Zbiór wynikowy
-- powinien zawierać imię i nazwisko członka biblioteki (dziecka), jego adres oraz tytuł wypożyczonej książki.
-- Jeśli jakieś dziecko mieszkająca w Arizonie nie ma wypożyczonej żadnej książki to też powinno znaleźć się
-- na liście, a w polu przeznaczonym na tytuł książki powinien pojawić się napis BRAK. (baza library)
SELECT m.firstname, m.lastname, a.street+', '+a.city+', '+a.[state]+', '+a.zip as adres, ISNULL(t.title,'BRAK') ksiazki FROM member m
JOIN juvenile j ON j.member_no = m.member_no
JOIN adult a ON a.member_no = j.adult_member_no
LEFT OUTER JOIN loan l ON l.member_no = m.member_no
LEFT OUTER JOIN title t ON t.title_no = l.title_no
WHERE a.[state] = 'AZ'

-- 3. Wyświetl numery zamówień złożonych w od marca do maja 1997, które były przewożone przez firmę 'United
-- Package' i nie zawierały produktów z kategorii "confections". (baza northwind)
SELECT DISTINCT o.OrderID FROM Orders o 
JOIN Shippers s ON s.ShipperID = o.ShipVia
WHERE s.CompanyName = 'United Package' AND o.OrderDate >= '1997.03.01' AND o.OrderDate < '1997.05.01' AND o.OrderID NOT IN (
    SELECT o.OrderID FROM Orders o
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Products p ON p.ProductID = od.ProductID
    JOIN Categories c ON c.CategoryID = p.CategoryID
    WHERE c.CategoryName = 'confections'
)

