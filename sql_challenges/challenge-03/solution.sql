1.SELECT Max(Years_employed) as years_employed, *
from employees
2.SELECT   Avg(years_employed ) as years_employed ,*
from employees
group by role
3.select sum(Years_employed) ,*
from employees 
group by building 


1.SELECT role, COUNT()
FROM employees 
where Role= "Artist"
2.SELECT role, COUNT()
FROM employees
GROUP BY role;
3.SELECT  sum(years_employed)
FROM employees 
where role="Engineer"



1.CREATE TABLE bricks (
    id NUMBER,
    shape VARCHAR2(20),
    weight NUMBER
);
INSERT INTO bricks VALUES (1,'cube',1);
INSERT INTO bricks VALUES (2,'cube',1);
INSERT INTO bricks VALUES (3,'sphere',2);
INSERT INTO bricks VALUES (4,'sphere',2);
INSERT INTO bricks VALUES (5,'pyramid',3);
SELECT
    COUNT(DISTINCT shape) AS number_of_shapes,
    STDDEV(DISTINCT weight) AS distinct_weight_stddev
FROM bricks;
2.SELECT
    shape,
    SUM(weight) AS shape_weight
FROM bricks
GROUP BY shape;
3.SELECT
    shape,
    SUM(weight)
FROM bricks
GROUP BY shape
HAVING SUM(weight) < 4;