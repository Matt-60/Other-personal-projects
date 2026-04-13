SELECT TOP (10) [customer_id]
      ,[first_name]
      ,[last_name]
      ,[email]
      ,[phone]
      ,[city]
      ,[age]
      ,[registration_date]
  FROM [Customers].[dbo].[silver_customers]

    -- Step 1: Columns overview, Changing data types

SELECT
    COUNT(DISTINCT customer_id),     AS Count_of_dist_customer_id,
    COUNT(DISTINCT first_name)       AS Count_of_dist_first_name,
    COUNT(DISTINCT last_name)        AS Count_of_dist_last_name,
    COUNT(DISTINCT email)            AS Count_of_dist_email,
    COUNT(DISTINCT phone)            AS Count_of_dist_phone,
    COUNT(DISTINCT city)             AS Count_of_dist_city,
    COUNT(DISTINCT age)              AS Count_of_dist_age,
    COUNT(DISTINCT registration_date) AS Count_of_dist_registration_date
FROM silver_customers;

SELECT DISTINCT customer_id FROM silver_customers;

SELECT DISTINCT first_name FROM silver_customers;

SELECT DISTINCT last_name FROM silver_customers;

SELECT DISTINCT email FROM silver_customers;

SELECT DISTINCT phone FROM silver_customers;

UPDATE silver_customers
SET phone = SUBSTRING(phone, 3, LEN(phone))
WHERE phone LIKE '48%';

SELECT DISTINCT city FROM silver_customers;

SELECT
    COUNT(*) AS total,
    COUNT(city) AS non_null,
    SUM(CASE WHEN city = 'NULL' THEN 1 ELSE 0 END) AS string_nulls
FROM silver_customers;

UPDATE silver_customers
SET city = NULL
WHERE city IN ('NULL');

SELECT DISTINCT age FROM silver_customers;

UPDATE silver_customers
SET age = NULL
WHERE age IN ('NULL', 'unknown');

ALTER TABLE silver_customers
ALTER COLUMN age INT;

SELECT DISTINCT registration_date FROM silver_customers;

UPDATE silver_customers
SET registration_date = NULL
WHERE registration_date LIKE 'NULL';

SELECT registration_date
FROM silver_customers
WHERE 
    TRY_CONVERT(DATE, registration_date, 105) IS NULL
    AND TRY_CONVERT(DATE, registration_date, 23) IS NULL
    AND registration_date IS NOT NULL;

UPDATE silver_customers
SET registration_date = CASE 
        WHEN registration_date LIKE '__-__-____' 
            THEN TRY_CONVERT(DATE, registration_date, 105)
        WHEN registration_date LIKE '____-__-__' 
            THEN TRY_CONVERT(DATE, registration_date, 23)
    END;

ALTER TABLE silver_customers
ALTER COLUMN registration_date DATE;

   -- Step 2: Data quality check

WITH data_quality_check AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        email,
        phone,
        city,
        age,
        registration_date,
        CASE 
            WHEN email NOT LIKE '%@%.%' THEN 'Invalid Email'
        END AS email_issue,
        CASE 
            WHEN age < '0' OR age > '120' THEN 'Invalid Age'
        END AS age_issue,
        CASE 
            WHEN phone IS NULL THEN 'Missing Phone'
        END AS phone_issue,
        CASE 
            WHEN city IS NULL THEN 'Missing City'
        END AS city_issue
    FROM silver_customers
)

SELECT *
FROM data_quality_check;

-- Step 3: Remove duplicates
WITH deduplicated AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id, email
            ORDER BY registration_date
        ) AS row_number
    FROM silver_customers
)

SELECT *
FROM deduplicated
WHERE row_number > 1;

-- Step 4: Standardize text formatting
SELECT
    customer_id,
    UPPER(LEFT(first_name,1)) + LOWER(SUBSTRING(first_name,2,LEN(first_name))),
    TRIM(UPPER(LEFT(last_name,1)) + LOWER(SUBSTRING(last_name,2,LEN(last_name)))) AS last_name,
    LOWER(TRIM(email)) AS email,
    TRIM(phone) AS phone,
    TRIM(UPPER(LEFT(city,1)) + LOWER(SUBSTRING(city,2,LEN(city)))) AS city,
    age,
    registration_date
FROM silver_customers;

-- Step 5: Handle missing values
SELECT
    COUNT(CASE WHEN customer_id IS NULL THEN 1 END)       AS null_customer_id,
    COUNT(CASE WHEN first_name IS NULL THEN 1 END)       AS null_first_name,
    COUNT(CASE WHEN last_name IS NULL THEN 1 END)        AS null_last_name,
    COUNT(CASE WHEN email IS NULL THEN 1 END)            AS null_email,
    COUNT(CASE WHEN phone IS NULL THEN 1 END)            AS null_phone,
    COUNT(CASE WHEN city IS NULL THEN 1 END)             AS null_city,
    COUNT(CASE WHEN age IS NULL THEN 1 END)              AS null_age,
    COUNT(CASE WHEN registration_date IS NULL THEN 1 END) AS null_registration_date
FROM silver_customers;

UPDATE silver_customers
SET 
    phone = COALESCE(phone, 'Not Provided'),
    city = COALESCE(city, 'Unknown')

select * from silver_customers

-- Step 6: Filter invalid records
SELECT *
FROM silver_customers
WHERE email not LIKE '%@%'
  or age not BETWEEN 0 AND 120

  -- Step 7: Enrich with calculated fields
SELECT
    customer_id,
    first_name,
    last_name,
    first_name + ' ' + last_name AS full_name,
    email,
    phone,
    city,
    age,
    registration_date,
    DATEDIFF(DAY, registration_date, GETDATE()) AS days_since_registration
FROM silver_customers;

  -- Step 8: Data type optimisation

SELECT
    MAX(LEN(CAST(customer_id AS VARCHAR)))       AS max_len_customer_id,
    MAX(LEN(first_name))                        AS max_len_first_name,
    MAX(LEN(last_name))                         AS max_len_last_name,
    MAX(LEN(email))                             AS max_len_email,
    MAX(LEN(phone))                             AS max_len_phone,
    MAX(LEN(city))                              AS max_len_city,
    MAX(LEN(CAST(age AS VARCHAR)))              AS max_len_age,
    MAX(LEN(CAST(registration_date AS VARCHAR))) AS max_len_registration_date
FROM silver_customers;

ALTER TABLE silver_customers
ALTER COLUMN customer_id VARCHAR(9);

ALTER TABLE silver_customers
ALTER COLUMN first_name VARCHAR(9);

ALTER TABLE silver_customers
ALTER COLUMN last_name NVARCHAR(10);

ALTER TABLE silver_customers
ALTER COLUMN email NVARCHAR(35);

ALTER TABLE silver_customers
ALTER COLUMN phone VARCHAR(12);

ALTER TABLE silver_customers
ALTER COLUMN city NVARCHAR(8);
