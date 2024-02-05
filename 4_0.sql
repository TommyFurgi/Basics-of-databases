select t.orderid, t.customerid
from (select orderid, customerid
from orders) as t

select productname, unitprice, (select avg(unitprice) from products) as average
from products;

select productname, unitprice, (select avg(unitprice) from products) as average, unitprice - (select avg(unitprice) from products) as diff
from products;

select productname, categoryid, unitprice
    ,( select avg(unitprice)
    from products as p_in
    where p_in.categoryid = p_out.categoryid ) as average
from products as p_out
WHERE UnitPrice > ( select avg(unitprice)
                    from products as p_in
                    where p_in.categoryid = p_out.categoryid )

SELECT *, UnitPrice - average FROM
(select productname, categoryid, unitprice
    ,( select avg(unitprice)
    from products as p_in
    where p_in.categoryid = p_out.categoryid ) as average
from products as p_out) t
WHERE UnitPrice > average

;with t as (
select productname, categoryid, unitprice
,( select avg(unitprice)
    from products as p_in
    where p_in.categoryid = p_out.categoryid ) as average
from products as p_out
)
select *, UnitPrice - average as diff from t
WHERE UnitPrice > average
