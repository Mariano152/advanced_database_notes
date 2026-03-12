1.SELECT Title
 From Movies

2.SELECT Director 
FROM movies;

3.SELECT Director,Title
FROM movies;

4.SELECT year,Title
FROM movies;

5.SELECT *
FROM movies;

1.SELECT* FROM movies 
WHERE id = 6;
2.SELECT * FROM movies
WHERE year BETWEEN 2000 AND 2010;
3.SELECT * FROM movies
WHERE year NOT BETWEEN 2000 AND 2010;
4.SELECT* FROM movies
WHERE year <= 2003;

1.SELECT* FROM movies 
WHERE title LIKE "Toy Story%";
2.SELECT* FROM movies 
WHERE director LIKE "John Lasseter";
3.SELECT* FROM movies 
WHERE director NOT LIKE "John Lasseter";
4.SELECT* FROM movies 
WHERE title  LIKE "WALL%";

1.SELECT DISTINCT *FROM movies
ORDER BY director ASC;

2.SELECT DISTINCT*
FROM movies
WHERE YEAR >= 2010
ORDER BY Year DESC

3.SELECT *
FROM movies
ORDER BY title ASC
LIMIT 5;

4.SELECT *
FROM movies
ORDER BY title ASC
LIMIT 5 OFFSET 5;

SELECT *
FROM page_likes
right Join  pages 
ON pages.page_id=page_likes.page_id
Where  user_id is  NULL
Order by pages.page_id  ASC


1.SELECT * FROM north_american_cities
WHERE country like "Canada"

2.SELECT * FROM north_american_cities
WHERE country like "United%"
Order by Latitude DESC

3.SELECT * FROM north_american_cities
WHERE LONGITUDE<-88
Order by LONGITUDE ASC

4.SELECT * FROM north_american_cities
WHERE country like "Mexico"
Order by population desc
limit 2

5.SELECT * FROM north_american_cities
WHERE country like "UNITED%"
Order by population desc
limit 2 offset 2



1.SELECT title,domestic_sales,international_sales
from Boxoffice
JOIN Movies
On movies.id=boxoffice.movie_id

2.SELECT title,domestic_sales,international_sales
from Boxoffice
JOIN Movies
On movies.id=boxoffice.movie_id
WHERE international_sales>domestic_sales

3.SELECT title,domestic_sales,international_sales,rating
from Boxoffice
JOIN Movies
On movies.id=boxoffice.movie_id
order by Rating desc



1.SELECT  Building
FROM employees
Join Buildings
On Buildings.building_name=Employees.building
WHERE Capacity>0 

2.SELECT distinct Building_name, capacity
FROM buildings

3.SELECT distinct Role, Building_name
FROM Buildings
 Left Join Employees
On Buildings.building_name=Employees.building
