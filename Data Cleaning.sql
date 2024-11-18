-- Have to create table with the column names in the csv file
CREATE TABLE layoffs (
	company TEXT,
	location TEXT,
	industry TEXT,
	total_laid_off TEXT,
	percentage_laid_off TEXT,
	date TEXT,
	stage TEXT,
	country TEXT,
	funds_raised_millions INT
);

SELECT * 
FROM layoffs;

-- Import the data from the csv file to fill the layoffs table
COPY layoffs(company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions)
FROM 'C:\Users\horic\OneDrive\Desktop\PostgreSQL stuff\layoffs.csv'
DELIMITER ','
CSV HEADER
NULL AS 'NULL';		

-- funds_raised_millions data type was INT when creating table, so had to change to FLOAT since the csv file has float values
ALTER TABLE layoffs
ALTER COLUMN funds_raised_millions TYPE FLOAT;


/**
		Before working on the data, create another staging table of the raw data and make changes on that.

		Data Cleaning Process

		1. Remove duplicates
		2. Standardize the data
		3. Null values or blank values
		4. Remove any columns
**/

SELECT *
FROM layoffs;


-- Staging layoffs table from the raw data to make changes to it
CREATE TABLE layoffs_staging
AS TABLE layoffs;


SELECT *
FROM layoffs_staging;


-- Using the ROW_NUMBER() window function to find the duplicates values (1's are unique values)
WITH layoffsCTE AS (
	SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
)
SELECT *
FROM layoffsCTE
WHERE row_num > 1
;

-- Double checking to see that these rows are actually duplicates
SELECT * FROM layoffs_staging WHERE company = 'Casper';
SELECT * FROM layoffs_staging WHERE company = 'Cazoo';
SELECT * FROM layoffs_staging WHERE company = 'Hibob';
SELECT * FROM layoffs_staging WHERE company = 'Wildlife Studios';
SELECT * FROM layoffs_staging WHERE company = 'Yahoo';


-- Create another table (same as layoffsCTE) to show the unique and duplicate values 
CREATE TABLE layoffs_staging2 (
	company TEXT,
	location TEXT,
	industry TEXT,
	total_laid_off TEXT,
	percentage_laid_off TEXT,
	date TEXT,
	stage TEXT,
	country TEXT,
	funds_raised_millions INT,
	row_num INT
);


SELECT * FROM layoffs_staging;

-- Insert the data with the row_num that shows duplicates into new staging table
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


SELECT * 
FROM layoffs_staging2;


-- Remove the duplicates
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;


/**  Standardize the data (look for issues in the data and fix it) **/

-- Checking the company column, we can see that there is white space in the beginning of some of the companies, so remove the white space
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- Removed any white space from the beginning and the end of the company name
UPDATE layoffs_staging2
SET company = TRIM(company);


/* 
	- Checking the industry column, we can see that there are inconsistencies. For example, the 'Crypto' industry has 3 names for it: 'Crypto', 
		'CryptoCurrency', & 'Crypto Currency'.
	- There is also a blank and null value.
*/
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;


--  Fix this issue by changing all these different names into just 'Crypto' to describe this industry
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


-- Checking all the other columns to see if there are any inconsistencies
SELECT * FROM layoffs_staging2;

SELECT DISTINCT location FROM layoffs_staging2 ORDER BY 1;
SELECT DISTINCT total_laid_off FROM layoffs_staging2 ORDER BY 1;
SELECT DISTINCT percentage_laid_off FROM layoffs_staging2 ORDER BY 1;
SELECT DISTINCT date FROM layoffs_staging2 ORDER BY 1;
SELECT DISTINCT stage FROM layoffs_staging2 ORDER BY 1;
SELECT DISTINCT country FROM layoffs_staging2 ORDER BY 1;
SELECT DISTINCT funds_raised_millions FROM layoffs_staging2 ORDER BY 1;


/*
	Some bad data in each column:
		- There are 2 'United States' in country (1 of it has a '.' at the end) 	(done; removed the '.' from countries that start with 'United States')
		- some have null/blank values
		- total_laid_off is a text data type	(done; changed it to INT type)
		- date column is text	(done; changed it to DATE type)
*/


UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';


ALTER TABLE layoffs_staging2
ALTER COLUMN percentage_laid_off TYPE FLOAT
USING percentage_laid_off::float;


ALTER TABLE layoffs_staging2
ALTER COLUMN total_laid_off TYPE float
USING total_laid_off::float;


SELECT date
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date = TO_DATE(date, 'MM/DD/YYYY');


ALTER TABLE layoffs_staging2
ALTER COLUMN date TYPE DATE
USING date::date;

SELECT date, EXTRACT(DAY FROM date)
from layoffs_staging2;


/** Handling the null values **/
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL;


SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';


SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';


SELECT t1.industry t1, t2.industry t2
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;


-- Filled the empty/null industries with its own company that is filled that is found within the table
UPDATE layoffs_staging2 AS t1
SET industry = t2.industry
FROM layoffs_staging2 AS t2
WHERE t1.company = t2.company 
	  AND t1.location = t2.location 
	  AND (t1.industry IS NULL OR t1.industry = '') 
	  AND t2.industry IS NOT NULL;











