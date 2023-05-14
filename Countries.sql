USE WORLD;

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
WHERE percentage < 10.0
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

-- Count the NULL values in all the columns
SELECT COUNT(CountryCode),COUNT(Language),COUNT(IsOfficial),COUNT(Percentage)
FROM countrylanguage
WHERE CountryCode IS NULL OR
	     Language IS NULL OR 
		IsOfficial IS NULL OR
        Percentage IS NULL ;

-- number of countries that speak the language --
SELECT DISTINCT(language) AS language ,COUNT(language) AS num_countries
FROM countrylanguage
GROUP BY language
ORDER BY num_countries DESC;

-- Total Surface Area of all the continents
SELECT Continent, SUM(SurfaceArea)
FROM country
GROUP BY Continent;

-- Averagre size of America Countries
SELECT Continent, AVG(SurfaceArea) AS Avg_Surf_Area
FROM country
WHERE Continent LIKE '%America'
GROUP BY Continent;

-- More and Less populated Country in Africa Option 1 --
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

-- More and Less populated Country in Africa Option 2 --

SELECT c1.Name, c1.Population
FROM country AS c1
INNER JOIN (
SELECT MIN(Population) AS MinPop, MAX(Population) AS MaxPop
FROM country
WHERE Continent = 'Africa') AS C2
ON c1.Population IN (c2.MinPop, c2.MaxPop)
WHERE c1.Continent = 'Africa'

-- show the countries by population and the life expectency

SELECT Name, population, LifeExpectancy
FROM country
ORDER BY Name , population DESC ;








