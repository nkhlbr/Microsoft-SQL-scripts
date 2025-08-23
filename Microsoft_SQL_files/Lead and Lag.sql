








SELECT BusinessEntityID, YEAR(QuotaDate) AS SalesYear, SalesQuota AS CurrentQuota, 
       LAG(SalesQuota, 1,0) OVER (ORDER BY YEAR(QuotaDate)) AS PreviousQuota
FROM Sales.SalesPersonQuotaHistory
WHERE BusinessEntityID = 275 and YEAR(QuotaDate) IN ('2005','2006');



select Yearto, Population,  LAG(Population,1,0) over (ORDER BY YEARTO) as LAGGINGPOPULATION, 

Population - (LAG(Population,1,0) over (ORDER BY YEARTO)) AS RESULT from DBO.#TEMPTBL 