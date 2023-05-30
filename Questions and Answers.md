## Questions and Answers

````sql
USE WORLD;
````

##### Count number of NULL values in IndepYear
````sql
SELECT COUNT(*) - COUNT(IndepYear) AS null_Values
FROM country;
````

##### Count the NULL values in the columns of the table countrylanguage
````sql
SELECT COUNT(CountryCode),COUNT(Language),COUNT(IsOfficial),COUNT(Percentage)
FROM countrylanguage
WHERE CountryCode IS NULL OR
	     Language IS NULL OR 
		IsOfficial IS NULL OR
        Percentage IS NULL ;
````

##### Total records in the table country,city,countrylanguage
````sql
SELECT COUNT(*) AS count_records_country
FROM country;
````


````sql
SELECT COUNT(*) AS count_records_city
FROM city;
````


````sql
SELECT COUNT(*) AS count_records_language
FROM countrylanguage;
````

##### Calculate the GNP per capita in each continent 
````sql
SELECT Continent , AVG((GNP / Population)) AS GNP_per_capita  
FROM country  
GROUP BY Continent
ORDER BY GNP_per_capita DESC;
````

##### Find the TOP 10 languages with more percentage 
````sql
SELECT language, percentage
FROM countrylanguage
ORDER BY percentage DESC
LIMIT 10;
````

##### find the TOP 10 countries with less than 50% in language --
````sql
SELECT language, percentage
FROM countrylanguage
WHERE percentage < 50.0
ORDER BY percentage DESC
LIMIT 10;
````

##### How many countries speak 'Spanish' OR 'English'
````sql
SELECT COUNT(*) AS counter
FROM countrylanguage
WHERE language = 'English' OR language ='Spanish';
````

##### How many countries speak 'German' with less 80 percentage
````sql
SELECT COUNT(*) AS counter
FROM countrylanguage
WHERE language = 'German' AND  percentage < 0.80;
````

##### How many countries speak 'Spanish, English, French and German' 
````sql
SELECT COUNT(*) AS counter
FROM countrylanguage
WHERE language IN ('Spanish', 'English', 'French','German');
````

##### number of countries that speak each language --
````sql
SELECT DISTINCT(language) AS language ,COUNT(language) AS num_countries
FROM countrylanguage
GROUP BY language
ORDER BY num_countries DESC 
LIMIT 10;
````

##### Total Surface Area of all the continents
````sql
SELECT Continent, SUM(SurfaceArea)
FROM country
GROUP BY Continent;
````

##### Average size of the countries in the American Continents
````sql
SELECT Continent, AVG(SurfaceArea) AS Avg_Surf_Area
FROM country
WHERE Continent LIKE '%America'
GROUP BY Continent;
````

##### Most and Less populated Country in Africa Option 1 --
````sql
SELECT *
FROM (
  SELECT Name, Population
  FROM country
  WHERE Continent = 'Africa'
  ORDER BY Population ASC
  LIMIT 1
) AS MinPop
UNION ALL
SELECT *
FROM (
  SELECT Name, Population
  FROM country
  WHERE Continent = 'Africa'
  ORDER BY Population DESC
  LIMIT 1
) AS MaxPop;
````

##### Most and Less populated Country in Africa Option 2 --
````sql
SELECT c1.Name, c1.Population
FROM country AS c1
INNER JOIN (
SELECT MIN(Population) AS MinPop, MAX(Population) AS MaxPop
FROM country
WHERE Continent = 'Africa') AS C2
ON c1.Population IN (c2.MinPop, c2.MaxPop)
WHERE c1.Continent = 'Africa';
````

##### show the countries by population and the life expectency
````sql
SELECT Name, population, LifeExpectancy
FROM country
ORDER BY Name , population DESC ;
````

##### Find the cities with the most population and surface area
````sql
SELECT city.Name AS City_Name, country.Name AS Country_Name, Continent, SurfaceArea, city.Population AS Population 
FROM city
INNER JOIN country
ON city.CountryCode = country.code
ORDER BY Population DESC ,  SurfaceArea DESC 
LIMIT 10;
````
##### English speakers countries with more than 60% of language, show with the GNP
````sql
SELECT Name, Continent, Region, GNP, Percentage
FROM country
INNER JOIN countrylanguage
ON country.Code = countrylanguage.CountryCode 
WHERE Language = 'English' AND Percentage > 60.0
ORDER BY GNP DESC ;
````

##### number of cities that speak each language and the average GDP 
````sql
SELECT COUNT(city.Name) AS number_cities, Language , AVG(GNP) AS avg_GDP
FROM country
INNER JOIN countrylanguage
ON country.Code = countrylanguage.CountryCode 
INNER JOIN city
ON country.Code = city.CountryCode 
GROUP BY Language 
ORDER BY number_cities DESC;
````

##### Number of cities per country
````sql
SELECT CountryCode, COUNT(CountryCode) AS Number_Cities
FROM city
LEFT JOIN country
ON city.CountryCode = country.code 
GROUP BY CountryCode
ORDER BY Number_Cities DESC  ;
````

##### capitals of the world: Life Expectancy, GNP per capita, Surface Area
````sql
SELECT city.Name , LifeExpectancy, (GNP/city.Population) AS GNP_per_capita , SurfaceArea
FROM country 
LEFT JOIN city
ON country.Capital = city.ID
WHERE city.Name IS NOT NULL
ORDER BY GNP_per_capita DESC;
````

##### most spoken languages in the cities around the word
````sql
WITH CTE AS (
SELECT Name, p1.CountryCode, District, Population, Language, Percentage
FROM city AS p1 
LEFT JOIN countrylanguage AS p2
ON p1.CountryCode = p2.CountryCode 
UNION
SELECT Name, p1.CountryCode, District, Population, Language, Percentage
FROM city AS p1 
RIGHT JOIN countrylanguage AS p2
ON p1.CountryCode = p2.CountryCode)
SELECT t1.CountryCode, t1.Name, t1.Language, t1.Percentage
FROM CTE AS t1 
INNER JOIN ( 
	SELECT CountryCode, Name, MAX(Percentage) AS MaxPercentage
    FROM CTE
    GROUP BY CountryCode, Name) AS t2 
ON t1.CountryCode = t2.CountryCode
AND t1.Name = t2.Name
AND t1.Percentage = t2.MaxPercentage;
````
##### most spoken languages in each country
````sql
WITH t3 AS (SELECT t1.CountryCode, t1.Language, t1.Percentage
FROM countrylanguage AS t1
INNER JOIN (
	SELECT CountryCode, MAX(Percentage) AS MaxPercentage
	FROM countrylanguage
	GROUP BY CountryCode) AS t2
ON t1.CountryCode = t2.CountryCode AND t1.Percentage = t2.MaxPercentage)
SELECT Name, Language, Percentage
FROM t3
LEFT JOIN country
ON t3.CountryCode = country.Code;
````





