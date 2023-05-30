USE WORLD;

-- Count number of NULL values in IndepYear
SELECT COUNT(*) - COUNT(IndepYear) AS null_Values
FROM country;

-- Count the NULL values in all the columns
SELECT COUNT(CountryCode),COUNT(Language),COUNT(IsOfficial),COUNT(Percentage)
FROM countrylanguage
WHERE CountryCode IS NULL OR
	     Language IS NULL OR 
		IsOfficial IS NULL OR
        Percentage IS NULL ;

-- Summarizing variable GNP per capita in continent
SELECT Continent , AVG((GNP / Population)) AS GNP_per_capita  
FROM country  
GROUP BY Continent
ORDER BY GNP_per_capita DESC;

-- Total records in the table country,city,countrylanguage
SELECT COUNT(*) AS count_records_country
FROM country;
SELECT COUNT(*) AS count_records_city
FROM city;
SELECT COUNT(*) AS count_records_language
FROM countrylanguage;

-- Count the languages and countries represented in the countrylanguage table
SELECT COUNT(DISTINCT(CountryCode)) AS countries,
	   COUNT(DISTINCT(Language)) AS language
FROM countrylanguage;

-- find the TOP 10 language with more percentage --
SELECT language, percentage
FROM countrylanguage
ORDER BY percentage DESC
LIMIT 10;

-- find the TOP 10 countries with less than 50% in language --
SELECT language, percentage
FROM countrylanguage
WHERE percentage < 50.0
ORDER BY percentage DESC
LIMIT 10;

-- How many countries speak 'Spanish' OR 'English'-- 
SELECT COUNT(*) AS counter
FROM countrylanguage
WHERE language = 'English' OR language ='Spanish';

-- How many countries speak 'German' with less 80 percentage-- 
SELECT COUNT(*) AS counter
FROM countrylanguage
WHERE language = 'German' AND  percentage < 0.80;

-- How many countries speak 'Spanish, English, French and German' 
SELECT COUNT(*) AS counter
FROM countrylanguage
WHERE language IN ('Spanish', 'English', 'French','German');



-- number of countries that speak each language --
SELECT DISTINCT(language) AS language ,COUNT(language) AS num_countries
FROM countrylanguage
GROUP BY language
ORDER BY num_countries DESC
LIMIT 10 ;

-- Total Surface Area of all the continents
SELECT Continent, SUM(SurfaceArea)
FROM country
GROUP BY Continent;

-- Average size of the countries in American Continents
SELECT Continent, AVG(SurfaceArea) AS Avg_Surf_Area
FROM country
WHERE Continent LIKE '%America'
GROUP BY Continent;

-- Most and Less populated Country in Africa Option 1 --
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

-- Most and Less populated Country in Africa Option 2 --

SELECT c1.Name, c1.Population
FROM country AS c1
INNER JOIN (
SELECT MIN(Population) AS MinPop, MAX(Population) AS MaxPop
FROM country
WHERE Continent = 'Africa') AS C2
ON c1.Population IN (c2.MinPop, c2.MaxPop)
WHERE c1.Continent = 'Africa';

-- show the countries by population and the life expectency

SELECT Name, population, LifeExpectancy
FROM country
ORDER BY Name , population DESC ;

-- Find the cities with the most population and surface area
SELECT city.Name AS City_Name, country.Name AS Country_Name, Continent, SurfaceArea, city.Population AS Population 
FROM city
INNER JOIN country
ON city.CountryCode = country.code
ORDER BY Population DESC ,  SurfaceArea DESC 
LIMIT 10;

-- English speakers countries with more than 60% of language, show with the GNP
SELECT Name, Continent, Region, GNP, Percentage
FROM country
INNER JOIN countrylanguage
ON country.Code = countrylanguage.CountryCode 
WHERE Language = 'English' AND Percentage > 60.0
ORDER BY GNP DESC ;

-- number of cities that speak each language and the average GDP  
SELECT COUNT(city.Name) AS number_cities, Language , AVG(GNP) AS avg_GDP
FROM country
INNER JOIN countrylanguage
ON country.Code = countrylanguage.CountryCode 
INNER JOIN city
ON country.Code = city.CountryCode 
GROUP BY Language 
ORDER BY number_cities DESC;

-- Number of cities per country
SELECT CountryCode, COUNT(CountryCode) AS Number_Cities
FROM city
LEFT JOIN country
ON city.CountryCode = country.code 
GROUP BY CountryCode
ORDER BY Number_Cities DESC  ;

-- capitals of the world: Life Expectancy, GNP per capita, Surface Area
SELECT city.Name , LifeExpectancy, (GNP/city.Population) AS GNP_per_capita , SurfaceArea
FROM country 
LEFT JOIN city
ON country.Capital = city.ID
WHERE city.Name IS NOT NULL
ORDER BY GNP_per_capita DESC;

-- most spoken languages in the cities around the word
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

-- most spoken languages in each country
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

-- Identyfing Group of Monarchs
SELECT HeadOfState ,  Nb_Countries
FROM (
SELECT HeadOfState, COUNT(Name) AS Nb_Countries
FROM country
GROUP BY HeadOfState) AS t1
WHERE Nb_Countries > 2 
ORDER BY Nb_Countries DESC ;

-- Identifying cities with the same name as the country
SELECT DISTINCT *
FROM (SELECT Name FROM city) AS c1 
INNER JOIN (SELECT Name FROM country) AS c2
ON c1.Name = c2.Name ;

SELECT Name FROM city
INTERSECT 
SELECT Name FROM country; 

-- Average percentage of Languages talk in South America
WITH SA_language AS 
(SELECT Language, Percentage 
FROM countrylanguage
WHERE CountryCode IN 
		(SELECT Code
		FROM country
		WHERE Region = 'South America') 
ORDER BY Percentage DESC ) 
SELECT Language, AVG(Percentage) AS AVG_Percentage
FROM SA_language
GROUP BY Language 
ORDER BY AVG_Percentage DESC ; 

-- Countrires above average Life Expectancy and GNP
SELECT Name, LifeExpectancy, GNP
FROM country
WHERE LifeExpectancy > (SELECT AVG(LifeExpectancy) 	FROM country WHERE Continent = 'Africa')  AND Continent = 'Africa'
ORDER BY LifeExpectancy DESC;

-- Number of cities per Country
DROP TABLE IF EXISTS new_tablename;
CREATE TEMPORARY TABLE new_tablename AS
SELECT country.Name AS country_name,
	( SELECT COUNT(*)
	  FROM city
      WHERE city.CountryCode = country.Code) AS nb_cities
FROM country 
ORDER BY nb_cities DESC ;

# correlation table between SurfaceArea, Population, LifeExpectancy, GNP
DROP TABLE IF EXISTS CORRELATIONS;
CREATE TEMPORARY TABLE CORRELATIONS AS
SELECT 'SurfaceArea' AS measure, 
		CORR( SurfaceArea,SurfaceArea) AS SurfaceArea,
        CORR( SurfaceArea,Population) AS Population,
        CORR( SurfaceArea,LifeExpectancy) AS LifeExpectancy,
		CORR( SurfaceArea,GNP) AS GNP
FROM COUNTRY;

INSERT INTO CORRELATIONS
SELECT 'Population' AS measure, 
		CORR( Population,SurfaceArea) AS SurfaceArea,
        CORR( Population,Population) AS Population,
        CORR( Population,LifeExpectancy) AS LifeExpectancy,
		CORR( Population,GNP) AS GNP
 FROM COUNTRY;
 
INSERT INTO CORRELATIONS
SELECT 'LifeExpectancy' AS measure, 
		CORR( LifeExpectancy,SurfaceArea) AS SurfaceArea,
        CORR( LifeExpectancy,Population) AS Population,
        CORR( LifeExpectancy,LifeExpectancy) AS LifeExpectancy,
		CORR( LifeExpectancy,GNP) AS GNP
 FROM COUNTRY;
 
INSERT INTO CORRELATIONS
SELECT 'GNP' AS measure, 
		CORR( GNP,SurfaceArea) AS SurfaceArea,
        CORR( GNP,Population) AS Population,
        CORR( GNP,LifeExpectancy) AS LifeExpectancy,
		CORR( GNP,GNP) AS GNP
 FROM COUNTRY;
 
 SELECT ROUND(SurfaceArea,2) AS SurfaceArea, 
		ROUND(Population,2) AS	Population,
        ROUND(LifeExpectancy,2) AS	LifeExpectancy, 
        ROUND(GNP,2) AS	GNP
 FROM COUNTRY;

-- form of governments 
SELECT DISTINCT(GovernmentForm) AS Gov_Form , COUNT(*)
FROM country
GROUP BY Gov_Form 
ORDER BY COUNT(*) DESC ;

SELECT DISTINCT(GovernmentForm) AS Gov_Form , COUNT(*)
FROM country
WHERE GovernmentForm LIKE '%Monarch%'
GROUP BY Gov_Form 
ORDER BY COUNT(*) DESC ;

-- Countries with more years of independency 
DROP TABLE IF EXISTS Independecy_years;
CREATE TEMPORARY TABLE Independecy_years AS
SELECT Name, YEAR(NOW()) - IndepYear AS Years_Independence
FROM country
ORDER BY Years_Independence DESC;

-- Histogram Table Independence years
SELECT
	bin_start,
    bin_end,
    COUNT(*) AS bin_count
FROM (
	SELECT Years_Independence,
    FLOOR( Years_Independence/100)*100 AS bin_start,
    FLOOR( Years_Independence/100)*100 + 100 AS bin_end
	FROM Independecy_years ) AS bin_subquery
WHERE bin_start IS NOT NULL
GROUP BY bin_start, bin_end
ORDER BY bin_start ; 

-- Number of Monarchy by Continents 
SELECT Continent, 
	  COUNT(CASE WHEN outcome = 'Monarchy' THEN Name END) AS Nb_Monarchy , 
      COUNT(CASE WHEN outcome = 'Other Form of Government' THEN Name END) AS Nb_Other_Govern
FROM (SELECT Name, Continent, 
		CASE WHEN GovernmentForm LIKE '%Monarch%' THEN 'Monarchy'
			 ELSE 'Other Form of Government'
             END AS outcome 
	  FROM country
      ORDER BY outcome DESC) AS Monarchy_Tb
GROUP BY Continent 
ORDER BY Nb_Monarchy DESC ;

-- Average variables in Europe
SELECT Continent,
	   AVG(CASE WHEN Continent = 'Europe' THEN SurfaceArea END) AS Avg_SurfArea,
       AVG(CASE WHEN Continent = 'Europe' THEN Population END) AS Avg_Population,
	   AVG(CASE WHEN Continent = 'Europe' THEN LifeExpectancy END) AS Avg_LifeExpectancy,
       AVG(CASE WHEN Continent = 'Europe' THEN GNP END) AS Avg_GNP
FROM country
WHERE Continent = 'Europe'
GROUP BY Continent ;

-- countries with better LifeExpectancy than average Europe
SELECT Name 
FROM country
WHERE LifeExpectancy > (
SELECT AVG(LifeExpectancy)
FROM country
WHERE  Continent = 'Europe' ) AND Continent != 'Europe';



-- A rank for the countries in function of the surface area 
SELECT 
	Name, 
    SurfaceArea,
    RANK() OVER(ORDER BY SurfaceArea DESC) AS SurfaceArea_Rank
FROM country;

-- Average surface area of the continent 
SELECT 
	Name,
    AVG(SurfaceArea) OVER(PARTITION BY Continent) AS Avg_Continent
FROM country





 



