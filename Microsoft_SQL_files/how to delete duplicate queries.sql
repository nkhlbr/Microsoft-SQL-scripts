--select * from Cm_Opt_Ttl_TrxResTL_S


WITH CTE AS(
       SELECT TempCalcValuesMVARemainingTerm, TempCalcValuesEffectiveDate, TreasuryRate, RN = ROW_NUMBER()OVER(PARTITION BY 
	   TempCalcValuesMVARemainingTerm, TempCalcValuesEffectiveDate ORDER BY TempCalcValuesMVARemainingTerm, TempCalcValuesEffectiveDate)
       FROM TreasuryRateTableDt
       )
       SELECT * FROM CTE WHERE CTE.RN > 1 


	   DELETE FROM CTE WHERE CTE.RN > 1 

	   --To Select Duplicates: 

WITH TRES AS(
       SELECT TempCalcValuesMVARemainingTerm, TempCalcValuesEffectiveDate, TreasuryRate, RN = ROW_NUMBER()
 OVER(PARTITION BY TempCalcValuesMVARemainingTerm, TempCalcValuesEffectiveDate 
ORDER BY TempCalcValuesMVARemainingTerm, TempCalcValuesEffectiveDate)
       FROM TreasuryRateTableDt
       )
       SELECT * FROM TRES WHERE TRES.RN > 1


--To Delete Duplicates

WITH TRES AS(
       SELECT TempCalcValuesMVARemainingTerm, TempCalcValuesEffectiveDate, TreasuryRate, RN = ROW_NUMBER()
                                                                                                                                                       OVER(PARTITION BY TempCalcValuesMVARemainingTerm, TempCalcValuesEffectiveDate 
                                                                                                                                                       ORDER BY TempCalcValuesMVARemainingTerm, TempCalcValuesEffectiveDate)
       FROM TreasuryRateTableDt
       )
       DELETE FROM TRES WHERE TRES.RN > 1



	   
;WITH CTE AS(
SELECT POH_POLICYNUMBER, RN = ROW_NUMBER()  
OVER (PARTITION BY POH_POLICYNUMBER ORDER BY POH_POLICYNUMBER) FROM cm_opt_poh_policyhdr_s)

SELECT distinct * FROM CTE WHERE CTE.RN = 2


SELECT * FROM cm_opt_poh_policyhdr_s WHERE POH_POLICYNUMBER is NULL  = 'KA13076796'


