# World-Life-Expectancy-Analysis


## Overview

This project analyzes the World Life Expectancy dataset using SQL. It includes data cleaning and exploratory data analysis (EDA) to derive meaningful insights and trends related to life expectancy worldwide.

## SQL Concepts Used

The following SQL functions and clauses were utilized in this project:

- **Aggregate Functions:** `COUNT`, `AVG`, `SUM`, `MAX`, `MIN`, `ROUND`
- **String Functions:** `DISTINCT`, `CONCAT`
- **Conditional Statements:** `CASE`
- **Analytical Functions:** `ROW_NUMBER`, `AVG (OVER PARTITION BY)`
- **Joins:** `INNER JOIN`, `SELF JOIN`
- **Filtering:** `WHERE`, `GROUP BY`, `HAVING`
- **Sorting:** `ORDER BY`, `LIMIT`
- **Subqueries:** Nested queries for complex analysis

## SQL Scripts

- **`data_cleaning.sql`** - Contains queries for:

  - Removing duplicate records
  - Populating missing values in the `status` and `life expectancy` columns
  - Standardizing the dataset for further analysis

- **`exploratory_data_analysis.sql`** - Includes queries for:

  - Understanding the dataset structure
  - Deriving key insights such as trends and country-wise analysis
  - Identifying missing values and calculating summary statistics

## Sample Analysis Questions

The EDA phase answers the following key questions:

1. What is the total number of records in the dataset?
2. How many unique countries are present in the dataset?
3. What are the distinct values in the `status` column?
4. Are there any missing values in key columns?
5. What is the overall average life expectancy?
6. How has the average life expectancy changed over the years?
7. Which countries have the highest and lowest life expectancy?
8. How does life expectancy vary between developed and developing countries?
9. Which countries have shown the most improvement in life expectancy?
10. What are the top 5 countries with the highest GDP?
11. What is the correlation between GDP and life expectancy?
12. Which countries have declining life expectancy trends?
13. What is the 5-year moving average of life expectancy for each country?
14. What is the average life expectancy by Country?
15. Which countries have the highest life expectancy compared to the previous year ?
16. What is the average life expectancy of each country?
17. How does the life expectancy change year over year for each country ?

## Future Improvements

- Performing deeper statistical analysis using Python (Pandas, Matplotlib, Seaborn)
- Building interactive dashboards using Power BI or Tableau
- Automating data updates using ETL pipelines




