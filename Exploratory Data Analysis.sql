/** EXPLORATORY DATA ANALYSIS **/

SELECT *
FROM layoffs_staging2;

/* 
	Date range of layoffs
	- The first recorded layoff in this dataset was in March 3, 2020 to March 6, 2023
*/
SELECT MIN(date), MAX(date)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

/* Companies that completely laid off their employees */
SELECT company, percentage_laid_off, total_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off = 1 AND total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC;

/* 
	Highest layoff in one day 
   	- Here, we can see that there were 12000 layoffs in a single day! That's a lot.
*/
SELECT MAX(total_laid_off)
FROM layoffs_staging2;


/*
	Looks like the top tech companies had the most layoffs (Google, Meta, Microsoft, Amazon)
*/
SELECT company, total_laid_off, percentage_laid_off, date
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC;


/* 
	All the 
*/
SELECT industry, SUM(total_laid_off) sum_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY sum_laid_off DESC;























