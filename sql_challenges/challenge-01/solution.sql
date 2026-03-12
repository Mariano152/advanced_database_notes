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
