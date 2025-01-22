-- ==============================
-- DATA CLEANING
-- ==============================


-- Retrieve all records from the world_life_expectancy table

SELECT *
FROM world_life_expectancy;

-- Identify duplicate records based on the combination of Country and Year
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

-- Find duplicate records and assign a row number to each duplicate set

SELECT *
FROM (
    SELECT Row_Id,
           CONCAT(Country, Year),
           ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
    FROM world_life_expectancy
) AS row_table
WHERE row_num > 1;

-- Remove duplicate records by keeping only the first occurrence

DELETE FROM world_life_expectancy
WHERE Row_ID IN (
    SELECT Row_ID
    FROM (
        SELECT Row_Id,
               CONCAT(Country, Year),
               ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
        FROM world_life_expectancy
    ) AS row_table
    WHERE row_num > 1
);

-- Find countries with missing status values

SELECT Country
FROM world_life_expectancy
WHERE status = '';

-- Check distinct status values where status is missing

SELECT DISTINCT(status)
FROM world_life_expectancy
WHERE status = '';

-- Populate missing status values with 'Developing' based on other available records for the same country

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.status = 'Developing'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developing';

-- Populate missing status values with 'Developed' based on other available records for the same country

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.status = 'Developed'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developed';

-- Retrieve all records after cleaning the data
SELECT *
FROM world_life_expectancy;

-- Identify records where Life Expectancy is missing and estimate the value using the average of adjacent years

SELECT t1.Country, t1.Year, t1.`Life expectancy`,
       t2.Country, t2.Year, t2.`Life expectancy`,
       t3.Country, t3.Year, t3.`Life expectancy`,
       ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1) AS estimated_life_expectancy
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.country = t2.country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.country = t3.country
    AND t1.Year = t3.Year + 1    
WHERE t1.`Life expectancy` = '';

-- Update missing Life Expectancy values by averaging the previous and next year's values

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.country = t2.country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.country = t3.country
    AND t1.Year = t3.Year + 1    
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2, 1)
WHERE t1.`Life expectancy` = '';





-- ==============================
-- EXPLORATORY DATA ANALYSIS (EDA)
-- ==============================


-- 1. What is the total number of records in the dataset?
SELECT COUNT(*) AS total_records 
FROM world_life_expectancy;

-- 2. How many unique countries are present in the dataset?
SELECT COUNT(DISTINCT Country) AS unique_countries 
FROM world_life_expectancy;

-- 3. What are the distinct values in the `status` column?
SELECT DISTINCT(status) 
FROM world_life_expectancy;

-- 4. Are there any missing values in key columns?
SELECT 
    SUM(CASE WHEN Country = '' OR Country IS NULL THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN `Life expectancy` = '' OR `Life expectancy` IS NULL THEN 1 ELSE 0 END) AS missing_life_expectancy,
    SUM(CASE WHEN status = '' OR status IS NULL THEN 1 ELSE 0 END) AS missing_status
FROM world_life_expectancy;

-- 5. What is the overall average life expectancy?
SELECT ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy 
FROM world_life_expectancy
WHERE `Life expectancy` IS NOT NULL;

-- 6. How has the average life expectancy changed over the years?
SELECT Year, ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy
FROM world_life_expectancy
WHERE `Life expectancy` IS NOT NULL
GROUP BY Year
ORDER BY Year;

-- 7. Which countries have the highest and lowest life expectancy?
SELECT Country, ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy
FROM world_life_expectancy
GROUP BY Country
ORDER BY avg_life_expectancy DESC
LIMIT 1;

SELECT Country, ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy
FROM world_life_expectancy
GROUP BY Country
ORDER BY avg_life_expectancy ASC
LIMIT 1;

-- 8. How does life expectancy vary between developed and developing countries?
SELECT status, ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy
FROM world_life_expectancy
WHERE `Life expectancy` IS NOT NULL
GROUP BY status;

-- 9. Which countries have shown the most improvement in life expectancy?
SELECT Country, (MAX(`Life expectancy`) - MIN(`Life expectancy`)) AS life_expectancy_improvement
FROM world_life_expectancy
GROUP BY Country
ORDER BY life_expectancy_improvement DESC
LIMIT 5;

-- 10. What are the top 5 countries with the highest GDP?
SELECT Country, MAX(GDP) AS highest_gdp
FROM world_life_expectancy
GROUP BY Country
ORDER BY highest_gdp DESC
LIMIT 5;

-- 11. What is the correlation between GDP and life expectancy?
SELECT Country ,ROUND(AVG(GDP),2) as GDP , ROUND(AVG(`Life expectancy`),2) as Life_Expectancy
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Expectancy > 0
AND GDP > 0
ORDER BY Life_Expectancy DESC ;


-- 12. Which countries have declining life expectancy trends?
SELECT Country 
FROM world_life_expectancy t1
WHERE `Life expectancy` < (
    SELECT AVG(`Life expectancy`)
    FROM world_life_expectancy t2
    WHERE t1.Country = t2.Country
)
GROUP BY Country;

-- 13. What is the 5-year moving average of life expectancy for each country?
SELECT Country, Year, 
       ROUND(AVG(`Life expectancy`) OVER (PARTITION BY Country ORDER BY Year ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING), 2) AS moving_avg
FROM world_life_expectancy;

-- 14. What is the average life expectancy by Country?
SELECT Country, ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy
FROM world_life_expectancy
GROUP BY Country;



-- 15. Which countries have the highest life expectancy compared to the previous year ?
SELECT t1.Country, t1.Year, t1.`Life expectancy` AS current_life_expectancy, 
       t2.`Life expectancy` AS previous_life_expectancy, 
       (t1.`Life expectancy` - t2.`Life expectancy`) AS life_expectancy_change
FROM world_life_expectancy t1
JOIN world_life_expectancy t2 
ON t1.Country = t2.Country AND t1.Year = t2.Year + 1
ORDER BY life_expectancy_change DESC
LIMIT 10;

-- 16. What is the average life expectancy of each country?
WITH country_avg_life AS (
    SELECT Country, ROUND(AVG(`Life expectancy`), 2) AS avg_life_expectancy
    FROM world_life_expectancy
    WHERE `Life expectancy` IS NOT NULL
    GROUP BY Country
)
SELECT * FROM country_avg_life
ORDER BY avg_life_expectancy DESC;

-- 17. How does the life expectancy change year over year for each country ?
WITH yearly_change AS (
    SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
           LAG(t1.`Life expectancy`) OVER (PARTITION BY t1.Country ORDER BY t1.Year) AS previous_year_life_expectancy
    FROM world_life_expectancy t1
)
SELECT Country, Year, `Life expectancy`, previous_year_life_expectancy, 
       (`Life expectancy` - previous_year_life_expectancy) AS change_in_life_expectancy
FROM yearly_change
WHERE previous_year_life_expectancy IS NOT NULL
ORDER BY Country, Year;