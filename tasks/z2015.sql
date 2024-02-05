-- 1.a) Wyświetl imię, nazwisko, dane adresowe oraz ilość wypożyczonych książek dla każdego członka biblioteki. Ilość wypożyczonych książek nie może być nullem, co najwyżej zerem.
SELECT m.lastname, m.firstname,(
    SELECT a.city FROM adult a
    WHERE a.member_no = m.member_no
    UNION
    SELECT aj.city FROM juvenile j
    JOIN adult aj on j.adult_member_no = aj.member_no
    WHERE j.member_no = m.member_no
) ,(
    SELECT COUNT(*) FROM loan l
    WHERE l.member_no = m.member_no
) FROM member m

-- b) j/w + informacja, czy dany członek jest dzieckiem
SELECT m.lastname, m.firstname,(
    SELECT a.city FROM adult a
    WHERE a.member_no = m.member_no
    UNION
    SELECT aj.city FROM juvenile j
    JOIN adult aj on j.adult_member_no = aj.member_no
    WHERE j.member_no = m.member_no
) ,(
    SELECT COUNT(*) FROM loan l
    WHERE l.member_no = m.member_no
), 
case 
    WHEN m.member_no IN (SELECT member_no FROM juvenile) THEN 'T'
    else 'N'
END 
as is_child
FROM member m


-- 2. wyświetl imiona i nazwiska osób, które nigdy nie wypożyczyły żadnej książki
-- a) bez podzapytań

SELECT m.member_no, m.firstname, m.lastname FROM member m
EXCEPT
SELECT m.member_no, m.firstname, m.lastname FROM member m
JOIN loan on loan.member_no = m.member_no
JOIN copy on copy.isbn = copy.isbn
JOIN loanhist ON loanhist.copy_no = copy.copy_no

-- 3. wyświetl numery zamówień, których cena dostawy była większa niż średnia cena za przesyłkę w tym roku
-- b) podzapytaniami
SELECT * FROM Orders o
WHERE Freight > (
    SELECT AVG(Freight) FROM orders o2
    WHERE YEAR(o2.OrderDate) = YEAR(o.OrderDate)
)

-- 4. wyświetl ile każdy z przewoźników miał dostać wynagrodzenia w poszczególnych latach i miesiącach.
SELECT 
    ShipVia,
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    SUM(Freight) AS TotalFreight
FROM Orders
GROUP BY ShipVia, YEAR(OrderDate), MONTH(OrderDate)
ORDER BY ShipVia, OrderYear, OrderMonth;
