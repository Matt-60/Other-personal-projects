SELECT TOP (100) * from layoffs1

SELECT Count(*) from layoffs1

--1. Changing data types

EXEC sp_help 'layoffs1';

SELECT 
    TRY_Cast(total_laid_off as int) AS LayoffDate
from layoffs1;

SELECT distinct(total_laid_off) from layoffs1

SELECT distinct total_laid_off
  from layoffs1
WHERE total_laid_off not like '%.0'

UPDATE layoffs1
SET total_laid_off = CAST(CAST(total_laid_off AS FLOAT) AS INT)

select total_laid_off*2 from layoffs1

ALTER TABLE layoffs1
ALTER COLUMN total_laid_off INT;

select date from layoffs1

select date from layoffs1
where date is null	

SELECT 
    TRY_CONVERT(DATE, [date], 101) AS LayoffDate
from layoffs1;

ALTER TABLE layoffs1
ALTER COLUMN date DATE;

SELECT 
    TRY_Cast(percentage_laid_off as float) AS LayoffDate,
    percentage_laid_off
from layoffs1;

ALTER TABLE layoffs1
ALTER COLUMN percentage_laid_off float;

SELECT 
    TRY_Cast(funds_raised as int) AS LayoffDate,
    funds_raised
from layoffs1;


ALTER TABLE layoffs1
ALTER COLUMN funds_raised float;

select date_added from layoffs1

select date_added from layoffs1
where date_added is null	

SELECT 
    TRY_CONVERT(DATE, date_added, 101) AS LayoffDate
from layoffs1;


ALTER TABLE layoffs1
ALTER COLUMN date_added DATE;

--- 2. Checking and removing duplicates

SELECT TOP (100) * from layoffs1

Select * from layoffs1 l
Join (
Select company, location, date from layoffs1
group by company, location, date
having count(*)>1
) l1 on l.company=l1.company AND l.location=l1.location AND l.date=l1.date
order by l.company

Select company, location, date, count(1) as cnt_of_dupl from layoffs1
group by company, location, date
having count(1)>1

Select * from layoffs1 l
Join (
Select company, location, date, total_laid_off from layoffs1
group by company, location, date, total_laid_off
having count(*)>1
) l1 on l.company=l1.company AND l.location=l1.location AND l.date=l1.date
order by l.company

Select * from layoffs1
where company = 'Oda' or company = 'Terminus'

WITH ranked AS (
SELECT
*,
ROW_NUMBER() OVER (
PARTITION BY company, location, date, total_laid_off
ORDER BY date_added
) AS rn
from layoffs1
)
SELECT *
FROM ranked
WHERE rn > 1
ORDER BY  rn;

WITH ranked AS (
SELECT
*,
ROW_NUMBER() OVER (
PARTITION BY company, location, date, total_laid_off
ORDER BY date_added
) AS rn
from layoffs1
)
SELECT count(*)
FROM ranked
WHERE rn > 1



BEGIN TRAN;

WITH ranked AS (
SELECT
*,
ROW_NUMBER() OVER (
PARTITION BY company, location, date, total_laid_off
ORDER BY date_added
) AS rn
from layoffs1
)
DELETE FROM ranked
WHERE rn > 1;

-- kontrola po
SELECT COUNT(*) AS duplicates_left
FROM (
Select company, location, date, total_laid_off from layoffs1
group by company, location, date, total_laid_off
having count(*)>1
) x;

ROLLBACK; -- Zamieñ na COMMIT, gdy wynik jest OK


 -- Próbka
WITH d AS (
Select company, location, date, total_laid_off from layoffs1
group by company, location, date, total_laid_off
having count(*)>1
)
SELECT TOP 20 *
FROM d
ORDER BY NEWID();

--3. Checking and cleaning columns

Select DISTINCT(TRIM(company)) from layoffs1

Select DISTINCT(company) from layoffs1

select * from layoffs1
where company is null

Select DISTINCT(location) from layoffs1

select * from layoffs1
where location is null

select * from layoffs1
where company = 'Product Hunt'

SELECT
    location,
    REPLACE(location, ', Non-U.S.', '') AS location_clean
from layoffs1
WHERE location LIKE '%, Non-U.S.%';



ALTER TABLE layoffs
ADD location_cleaned NVARCHAR(255);
UPDATE layoffs
SET location_cleaned = location;

UPDATE layoffs
SET location_cleaned = REPLACE(location_cleaned, ', Non-U.S.', '')
WHERE location_cleaned LIKE '%, Non-U.S.%';

Select DISTINCT(location_cleaned) from layoffs1

select * from layoffs1
where location_cleaned is null

select * from layoffs1
where total_laid_off is null


select min(total_laid_off), max(total_laid_off) from layoffs1

select * from layoffs1
where [date] is null

select min(date), max(date) from layoffs1

select * from layoffs1
where percentage_laid_off is null

select min(percentage_laid_off), max(percentage_laid_off) from layoffs1

select * from layoffs1
where industry is null

select * from layoffs1
where company = 'Eyeo' or company = 'Appsmith'

select distinct(industry) from layoffs1

select distinct(stage) from layoffs1

select * from layoffs1 l
left join layoffs l1
on l.company=l1.company
where l1.stage is null

select min(funds_raised), max(funds_raised) from layoffs1

select * from layoffs1
where funds_raised is null

select * from layoffs1
where country is null

UPDATE layoffs
SET country = CASE
    WHEN location_cleaned = 'Montreal' THEN 'Canada'
    WHEN location_cleaned = 'Berlin' THEN 'Germany'
END
WHERE country IS NULL;

select distinct(country) from layoffs1

select * from layoffs1
where date_added is null

select min(date_added), max(date_added) from layoffs1

select *, DATEDIFF(day, [date], date_added) as daydiff from layoffs1
where DATEDIFF(day, [date], date_added) <0 

--EDA
select company, count(*) as num_of_layoffs, AVG(total_laid_off) as avg_layoffs, SUM(total_laid_off) as sum_layoffs from layoffs1
group by company
order by AVG(total_laid_off) desc

select (select count(*) from layoffs1
where total_laid_off is null)*100.0/count(*) from layoffs1

select * from layoffs1
where total_laid_off is null

select country,   count(*) as num_of_layoffs, AVG(total_laid_off) as avg_layoffs, SUM(total_laid_off) as sum_layoffs from layoffs1
group by country
order by AVG(total_laid_off) desc

select industry,   count(*) as num_of_layoffs, AVG(total_laid_off) as avg_layoffs, SUM(total_laid_off) as sum_layoffs from layoffs1
group by industry
order by AVG(total_laid_off) desc

select YEAR([date]) as Year, count(*) as num_of_layoffs, AVG(total_laid_off) as avg_layoffs, SUM(total_laid_off) as sum_layoffs  from layoffs1
group by YEAR([date])
order by YEAR([date])

select LEFT(DATETRUNC(month,[date]),7) as [Year-month], count(*) as num_of_layoffs, AVG(total_laid_off) as avg_layoffs, SUM(total_laid_off) as sum_layoffs  from layoffs1
group by DATETRUNC(month,[date])
order by DATETRUNC(month,[date])


-- eda wczesniejsze
-- EDA

# Basic overview ----------------------------------------------------------------------------------------------------------------------------

SELECT * 
from layoffs1;

SELECT MIN(date), max(date)
from layoffs1;

SELECT MAX(total_laid_off)
from layoffs1;
    
-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
from layoffs1
WHERE  percentage_laid_off IS NOT NULL;
    
-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
from layoffs1
WHERE  percentage_laid_off = 1;

-- these are mostly startups it looks like who all went out of business during this time

-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT *
from layoffs1
WHERE  percentage_laid_off = 1
ORDER BY funds_raised DESC;

# Going into more details with use of group by --------------------------------------------------------------------------------------------------

-- Companies with the biggest single Layoff

SELECT TOP 10 company, total_laid_off
from layoffs1
ORDER BY 2 DESC


-- Companies with the most Total Layoffs

SELECT TOP 10 company, SUM(total_laid_off)
from layoffs1
GROUP BY company
ORDER BY 2 DESC


# Quering Total Layoffs by other columns ---------------------------------------------------------------------------------------------------------

-- by industry

SELECT industry, SUM(total_laid_off)
from layoffs1
GROUP BY industry
ORDER BY 2 DESC;

-- by country

SELECT country, SUM(total_laid_off)
from layoffs1
GROUP BY country
ORDER BY 2 DESC;

-- per year

SELECT YEAR(date), SUM(total_laid_off)
from layoffs1
GROUP BY YEAR(date)
ORDER BY 1 ASC;

-- by stage

SELECT stage, SUM(total_laid_off)
from layoffs1
GROUP BY stage
ORDER BY 2 DESC;

-- by location
SELECT TOP 10 location, SUM(total_laid_off)
from layoffs1
GROUP BY location
ORDER BY 2 DESC

# Querying total layoffs per period -----------------------------------------------------------------------------------------------------------------------

## per month:

-- Rolling Total of Layoffs Per Month

select LEFT(DATETRUNC(month,[date]),7) as dates, count(*) as num_of_layoffs, AVG(total_laid_off) as avg_layoffs, SUM(total_laid_off) as sum_layoffs  from layoffs1
group by LEFT(DATETRUNC(month,[date]),7)
order by LEFT(DATETRUNC(month,[date]),7)

WITH DATE_CTE AS 
(
select LEFT(DATETRUNC(month,[date]),7) as dates, SUM(total_laid_off) as sum_layoffs  from layoffs1
group by LEFT(DATETRUNC(month,[date]),7)
)

SELECT dates, SUM(sum_layoffs)  OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;

## Per year:

-- TOP 3 companies per year by total laid off

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  from layoffs1
  GROUP BY company, YEAR(date)
),
 Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

-- TOP 3 countries per year by total laid off

WITH Country_Year AS 
(
  SELECT country, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  from layoffs1
  GROUP BY country, YEAR(date)
),
 Country_Year_Rank AS (
  SELECT country, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Country_Year
)
SELECT country, years, total_laid_off, ranking
FROM Country_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

-- TOP 3 industries per year by total laid off

WITH Industry_Year AS 
(
  SELECT industry, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  from layoffs1
  GROUP BY industry, YEAR(date)
),
 Industry_Year_Rank AS (
  SELECT industry, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Industry_Year
)

SELECT industry, years, total_laid_off, ranking
FROM Industry_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;
