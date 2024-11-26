/** EXPLORATORY DATA ANALYSIS **/

SELECT *
FROM layoffs_staging2;

/* 
	Date range of layoffs
	- The first recorded layoff in this dataset was in March 3, 2020 to March 6, 2023.
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
	Looks like the top tech companies had the most layoffs (Google, Meta, Microsoft, Amazon).
*/
SELECT company, total_laid_off, percentage_laid_off, date
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC;


/* 
	All the layoffs within each industry.
*/
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


/*
	Sum of layoffs throughout the months and years.
*/
SELECT SUBSTRING(date::TEXT FROM 1 FOR 7) AS month_year, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(date::TEXT FROM 1 FOR 7) IS NOT NULL
GROUP BY month_year
ORDER BY 1 ASC;


/*
	- Utilizing a CTE and a window function to find the rolling sum of layoffs of each month.
	- We can use a data visualization to visualize the amount of layoffs in each month and how much the layoffs increases over time.
*/
WITH Rolling_Sum AS
(
	SELECT SUBSTRING(date::TEXT FROM 1 FOR 7) AS month_year, SUM(total_laid_off) AS years_layoffs
	FROM layoffs_staging2
	WHERE SUBSTRING(date::TEXT FROM 1 FOR 7) IS NOT NULL
	GROUP BY month_year
	ORDER BY 1 ASC
)
SELECT month_year, years_layoffs, SUM(years_layoffs) OVER(ORDER BY month_year) AS rolling_sum
FROM Rolling_Sum;


/*
	The rolling sum of the amount of layoffs from each company based on each year.
*/
SELECT company, SUBSTRING(date::TEXT FROM 1 FOR 4) AS year, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, year
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY 3 DESC;


/*
	Ranking the amount of layoffs based on the number of total layoffs in each year and the top 5 in each year
*/
WITH Company_Year (company, years, total_laid_off) AS
(
	SELECT company, SUBSTRING(date::TEXT FROM 1 FOR 4), SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY company, SUBSTRING(date::TEXT FROM 1 FOR 4)
	HAVING SUM(total_laid_off) IS NOT NULL
	ORDER BY 3 DESC
),
Company_Year_Rankings AS
(
	SELECT *,
	DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off) AS Ranking
	FROM layoffs_staging2
)
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off) AS layoff_ranking
FROM Company_Year
WHERE years IS NOT NULL;













/*
	Overall findings of the analysis.

	- 
*/





