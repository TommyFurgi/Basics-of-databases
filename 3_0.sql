-- 1. Wybierz nazwy i ceny produktów (baza northwind) o cenie jednostkowej pomiędzy 20.00 a 30.00, dla każdego
-- produktu podaj dane adresowe dostawcy
SELECT ProductName,UnitPrice,Suppliers.Address,Suppliers.City FROM Products
INNER JOIN Suppliers
ON Products.SupplierID=Suppliers.SupplierID
WHERE UnitPrice BETWEEN 20 AND 30

-- 2. Wybierz nazwy produktów oraz inf. o stanie magazynu dla produktów dostarczanych przez firmę ‘Tokyo
-- Traders’
SELECT ProductName,UnitsInStock FROM Products
INNER JOIN Suppliers
ON Products.SupplierID=Suppliers.SupplierID
WHERE Suppliers.CompanyName = 'Tokyo Traders'

-- 3. Czy są jacyś klienci którzy nie złożyli żadnego zamówienia w 1997 roku, jeśli tak to pokaż ich dane adresowe
SELECT Customers.CustomerID,CompanyName,Address FROM Customers
LEFT OUTER JOIN Orders
ON Customers.CustomerID = Orders.CustomerID AND YEAR(OrderDate) = 1997 
WHERE OrderDate IS NULL

-- 4. Wybierz nazwy i numery telefonów dostawców, dostarczających produkty, których aktualnie nie ma w
-- magazynie
SELECT CompanyName,Phone FROM Suppliers
LEFT OUTER JOIN Products
ON Suppliers.SupplierID=Products.SupplierID
WHERE UnitsInStock IS null OR UnitsInStock = 0

-- 1. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (baza library). Interesuje nas imię,
-- nazwisko i data urodzenia dziecka.
SELECT firstname,lastname,birth_date FROM member
INNER JOIN juvenile
ON member.member_no=juvenile.member_no

-- 2. Napisz polecenie, które podaje tytuły aktualnie wypożyczonych książek
SELECT DISTINCT title FROM loan
INNER JOIN title
ON loan.title_no=title.title_no

-- 3. Podaj informacje o karach zapłaconych za przetrzymywanie książki o tytule ‘Tao Teh
-- Kingʼ. Interesuje nas data oddania książki, ile dni była przetrzymywana i jaką
-- zapłacono karę
SELECT in_date, DATEDIFF(day, due_date, in_date) AS DAYS, fine_paid
FROM loanhist
JOIN title
ON loanhist.title_no=title.title_no
WHERE title LIKE 'Tao Teh King' AND DATEDIFF(day, due_date, in_date)>0

-- 4. Napisz polecenie które podaje listę książek (mumery ISBN) zarezerwowanych przez
-- osobę o nazwisku: Stephen A. Graff
SELECT DISTINCT isbn, firstname +' '+ middleinitial +'. '+ lastname as fullName FROM reservation
INNER JOIN member
ON reservation.member_no=member.member_no
WHERE firstname LIKE 'Stephen' AND middleinitial LIKE 'A' AND lastname = 'Graff'


-- Napisz polecenie zwracające listę produktów które były zamawiane w dniu 1996-07-08
select distinct productname 
from orders as O
inner join [order details] as OD
on O.orderid = OD.orderid 
inner join products as P
on OD.productid = P.productid 
WHERE orderdate = '1996-07-08'


-- Napisz polecenie zwracające listę produktów które nie były zamawiane w dniu 1996-07-08
select ProductName
from products
EXCEPT
select distinct productname 
from orders as O
inner join [order details] as OD
on O.orderid = OD.orderid 
inner join products as P
on OD.productid = P.productid 
WHERE orderdate = '1996-07-08'

-- Napisz polecenie zwracające listę produktów, które nie były zamówione w dniu 1996-07-08
SELECT DISTINCT P.ProductName
FROM Products AS P
WHERE ProductName NOT IN
(select distinct ProductName
from orders as O
inner join [order details] as OD
on O.orderid = OD.orderid 
inner join products as P
on OD.productid = P.productid 
WHERE orderdate = '1996-07-08')


SELECT DISTINCT P.ProductName
FROM Products AS P
LEFT OUTER JOIN [order details] AS OD ON P.ProductID = OD.ProductID
LEFT OUTER JOIN Orders AS O ON O.OrderID = OD.OrderID AND O.OrderDate = '1996-07-08'
-- ORDER BY ProductName
-- WHERE O.OrderID IS NULL
GROUP BY P.ProductName
HAVING COUNT(O.OrderID)<2


select distinct p.ProductName 
from Products as p
LEFT JOIN [Order Details] as od on od.ProductID = p.ProductID
LEFT JOIN orders as o on o.OrderID = od.OrderID and o.OrderDate = '1996-07-08'


-- 1. Wybierz nazwy i ceny produktów (baza northwind) o cenie jednostkowej pomiędzy
-- 20.00 a 30.00, dla każdego produktu podaj dane adresowe dostawcy, interesują nas
-- tylko produkty z kategorii ‘Meat/Poultryʼ
SELECT ProductName,UnitPrice,Suppliers.Address,Suppliers.City FROM Products
INNER JOIN Suppliers
ON Products.SupplierID=Suppliers.SupplierID
INNER JOIN Categories
ON Products.CategoryID=Categories.CategoryID 
WHERE UnitPrice BETWEEN 20 AND 30 AND CategoryName = 'Meat/Poultry'

-- 2. Wybierz nazwy i ceny produktów z kategorii ‘Confectionsʼ dla każdego produktu podaj
-- nazwę dostawcy.
SELECT DISTINCT ProductName,UnitPrice,CompanyName FROM Products
INNER JOIN Suppliers
ON Products.SupplierID=Suppliers.SupplierID
INNER JOIN Categories
ON Products.CategoryID=Categories.CategoryID 
WHERE CategoryName = 'Confections'

-- 3. Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłki
-- dostarczała firma ‘United Packageʼ
SELECT DISTINCT Customers.CompanyName, Customers.Phone
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
INNER JOIN Shippers ON Orders.ShipVia = Shippers.ShipperID
WHERE  YEAR(Orders.ShippedDate) = 1997 AND Shippers.CompanyName = 'United Package' 

--3.1 Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłek nie dostarczała firma ‘United Packageʼ
SELECT DISTINCT Customers.CompanyName, Customers.Phone
FROM Customers
EXCEPT
SELECT DISTINCT Customers.CompanyName, Customers.Phone
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
INNER JOIN Shippers ON Orders.ShipVia = Shippers.ShipperID
WHERE  YEAR(Orders.ShippedDate) = 1997 AND Shippers.CompanyName = 'United Package' 

SELECT DISTINCT Customers.CompanyName, Customers.Phone
FROM Customers
WHERE Customers.CompanyName NOT IN
(SELECT DISTINCT Customers.CompanyName
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
INNER JOIN Shippers ON Orders.ShipVia = Shippers.ShipperID
WHERE  YEAR(Orders.ShippedDate) = 1997 AND Shippers.CompanyName = 'United Package')


-- 4. Wybierz nazwy i numery telefonów klientów, którzy kupowali produkty z kategorii
-- ‘Confectionsʼ
SELECT DISTINCT Customers.CompanyName,Customers.Phone FROM Customers
INNER JOIN Orders
ON Customers.CustomerID=Orders.CustomerID
INNER JOIN [Order Details]
ON [Order Details].OrderID=Orders.OrderID
INNER JOIN Products
ON [Order Details].ProductID=Products.ProductID
INNER JOIN Categories
ON Products.CategoryID=Categories.CategoryID 
WHERE CategoryName = 'Confections'

-- 4.1 Wybierz nazwy i numery telefonów klientów, którzy nie kupowali produktów z kategorii   
 -- ‘Confectionsʼ-- 
 
-- 4.1 Wybierz nazwy i numery telefonów klientów, którzy w 1997 nie kupowali produktów z kategorii    
-- ‘Confectionsʼ

-- 1. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (baza
-- library). Interesuje nas imię, nazwisko, data urodzenia dziecka i adres zamieszkania
-- dziecka.
SELECT firstname,lastname,birth_date, CONCAT(street, ' ', city, ' ',[state], ' ', zip) FROM member
INNER JOIN juvenile
ON member.member_no = juvenile.member_no
INNER JOIN adult
ON juvenile.adult_member_no = adult.member_no


-- 2. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (baza
-- library). Interesuje nas imię, nazwisko, data urodzenia dziecka, adres zamieszkania
-- dziecka oraz imię i nazwisko rodzica.
select m.member_no,m.firstname + ' ' + m.lastname as child_name, 
    j.birth_date, a.street + ', ' + a.city + ', ' + a.state,       am.firstname + ' ' + am.lastname as parent_name from member as m
join juvenile as j        
on m.member_no = j.member_no   
join adult as a        
on j.adult_member_no = a.member_no    
join member as am        
on a.member_no = am.member_no


/*2. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki (bazalibrary). Interesuje nas imię, nazwisko, data urodzenia 
dziecka, adres zamieszkaniadziecka oraz imię i nazwisko rodzica*/
SELECT m.member_no, m.firstname, m.lastname, j.birth_date, ad.street, ad.city, ad.zip, ad.state, ma.firstname, ma.lastname FROM member AS m    
INNER JOIN juvenile AS j ON m.member_no = j.member_no    
LEFT OUTER JOIN adult AS a ON m.member_no = a.member_no  -- nie potrzrebne  
INNER JOIN adult AS ad ON j.adult_member_no = ad.member_no    
INNER JOIN member AS ma ON ad.member_no = ma.member_no


-- 1. Napisz polecenie, które wyświetla pracowników oraz ich podwładnych (baza
-- northwind)
 SELECT e.EmployeeID, e.LastName as 'pracownik', p.EmployeeID, p.LastName as podwładny
 from Employees e 
 left outer JOIN Employees p
 on p.ReportsTo=e.EmployeeID
 where p.EmployeeID is NOT null


-- 2. Napisz polecenie, które wyświetla pracowników, którzy nie mają podwładnych (baza
 -- northwind) 
 SELECT e.EmployeeID, e.LastName 'pracownik', p.EmployeeID, p.LastName podwładny
 from Employees e 
 left outer JOIN Employees p
 on p.ReportsTo=e.EmployeeID
 where p.EmployeeID is null


-- 3. Napisz polecenie, które wyświetla adresy członków biblioteki, którzy mają dzieci
-- urodzone przed 1 stycznia 1996 (baza library)
SELECT DISTINCT adult.member_no, CONCAT(street, ' ', city, ' ',[state], ' ', zip) as adress FROM adult
INNER JOIN juvenile
ON adult.member_no = juvenile.adult_member_no
WHERE juvenile.birth_date < '1996-01-01'


-- 4. Napisz polecenie, które wyświetla adresy członków biblioteki, którzy mają dzieci
-- urodzone przed 1 stycznia 1996. Interesują nas tylko adresy takich członków
-- biblioteki, którzy aktualnie nie przetrzymują książek. (baza library)
SELECT DISTINCT adult.member_no, CONCAT(adult.street, ' ', adult.city, ' ', adult.state, ' ', adult.zip) AS address
FROM adult
LEFT JOIN juvenile ON adult.member_no = juvenile.adult_member_no
INNER JOIN member ON member.member_no = adult.member_no
LEFT JOIN loan ON adult.member_no = loan.member_no
WHERE juvenile.birth_date < '1996-01-01' 
AND loan.isbn IS NULL


-- 1. Podaj listę członków biblioteki mieszkających w Arizonie (AZ) mają więcej niż dwoje
-- dzieci zapisanych do biblioteki
SELECT member_no FROM adult
WHERE [state] = 'AZ'
INTERSECT
SELECT adult.member_no FROM adult
INNER JOIN juvenile ON adult.member_no = juvenile.adult_member_no
GROUP BY adult.member_no
HAVING  COUNT(juvenile.member_no) > 2


-- 2. Podaj listę członków biblioteki mieszkających w Arizonie (AZ) którzy mają więcej niż
-- dwoje dzieci zapisanych do biblioteki oraz takich którzy mieszkają w Kaliforni (CA) i
-- mają więcej niż troje dzieci zapisanych do biblioteki

(SELECT member_no FROM adult
WHERE [state] = 'AZ'
INTERSECT
SELECT adult.member_no FROM adult
INNER JOIN juvenile ON adult.member_no = juvenile.adult_member_no
GROUP BY adult.member_no
HAVING  COUNT(juvenile.member_no) > 2)
UNION
(SELECT member_no FROM adult
WHERE [state] = 'CA'
INTERSECT
SELECT adult.member_no FROM adult
INNER JOIN juvenile ON adult.member_no = juvenile.adult_member_no
GROUP BY adult.member_no
HAVING  COUNT(juvenile.member_no) < 3)
