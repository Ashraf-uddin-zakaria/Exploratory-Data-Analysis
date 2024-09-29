SELECT *
FROM layoff_Staging2;

# Maximum People Terminated in a single day by which company
SELECT MAX(total_laid_off)
FROM layoff_Staging2;
##Answer: MAX(total_laid_off)=12000
SELECT Company, Country, Industry, MAX(total_laid_off) as Maximum_People_Terminated
FROM layoff_Staging2
	WHERE total_laid_off=12000
GROUP BY Company, Country, Industry;

# Which companies are totally closed
SELECT *
FROM layoff_Staging2
	WHERE percentage_laid_off=1
    AND total_laid_off IS NOT NULL
    ORDER BY total_laid_off DESC ;

#Which company terminated maximum people
SELECT company, SUM(total_laid_off)
FROM layoff_Staging2
GROUP BY company
ORDER BY 2 DESC;

#Layoff date range
SELECT MIN(`date`) Layoff_started, MAX(`date`) Layoff_end
FROM layoff_Staging2;

#Yearly layoff data
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoff_Staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

#Monthly layoff data
SELECT SUBSTRING(`date`,1,7) as `Month`,SUM(total_laid_off) AS Monthly_layoff
FROM layoff_Staging2
	WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY `Month`;

#Rolling total by month
With Rolling_Total_Table AS
	(
    SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS Monthly_layoff
	FROM layoff_Staging2
		WHERE SUBSTRING(`date`,1,7) IS NOT NULL
	GROUP BY `Month`
	ORDER BY `Month`
    )
SELECT `Month`, Monthly_layoff, SUM(Monthly_layoff) OVER(ORDER BY `Month`) AS Rolling_Total
FROM Rolling_Total_Table
GROUP BY `Month`, Monthly_layoff;

####Top 5 company ranking on the base of layoff by year
#Step 1 Prepared data for company, Years, Total_laid
#Step 2 Name it Ranking_Table
#Step 3 Write code for ranking base on layoff by year
#Step 4 Name it Company_Year_Rank
#Step 5 Write code for Top 5 layoff company by using Company_Year_Rank table

SELECT company, YEAR(`date`) as Years, SUM(total_laid_off) as Total_laid
FROM layoff_Staging2
GROUP BY company, Years;

WITH Ranking_Table AS
	(
    SELECT company, YEAR(`date`) as Years, SUM(total_laid_off) as Total_laid
	FROM layoff_Staging2
	GROUP BY company, Years
    ), Company_Year_Rank AS
		(
		SELECT company, Years, Total_laid, RANK() OVER(PARTITION BY Years ORDER BY Total_laid DESC) AS Ranking
		FROM Ranking_Table
		WHERE Years IS NOT NULL
        )
	SELECT *
    FROM Company_Year_Rank
		WHERE Ranking<=5;
