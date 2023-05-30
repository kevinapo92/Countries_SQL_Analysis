### Questions and Answers

````sql
USE WORLD;
````


##### Count number of NULL values in IndepYear
````sql
SELECT COUNT(*) - COUNT(IndepYear) AS null_Values
FROM country;
````


##### Calculate the GNP per capita in each continent 
````sql
SELECT Continent , AVG((GNP / Population)) AS GNP_per_capita  
FROM country  
GROUP BY Continent
ORDER BY GNP_per_capita DESC
LIMIT 10 ;
````

![image](https://github.com/kevinapo92/World_SQL_Analysis/assets/96119396/db8914df-ecc7-4db0-82f8-2d46e700d2f7)
