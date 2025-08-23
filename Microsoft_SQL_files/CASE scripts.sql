


ISNULL(CASE_RoleDestination) ?  FALSE  : CASE_RoleDestination == "PolicyHdr"    conditional split
-------------------------------------------------------------------------------------------------------------------
select Pst_ID_I, Category = CASE Pst_DESCRIPTION_I
         WHEN 'Active' THEN 'Road'
         WHEN 'Disability' THEN 'Mountain'
         WHEN 'Daily Cost' THEN 'Touring'
         WHEN 'Expired' THEN 'Other sale items'
         ELSE 'Issued'
      END
	  from Cm_Sys_Pst_PolicyStatus_I
	  order by Pst_ID_I
	  go
-------------------------------------------------------------------------------------------------------------------


UPDATE HumanResources.Employee
SET VacationHours = 
    ( CASE
         WHEN ((VacationHours - 10.00) < 0) THEN VacationHours + 40
         ELSE (VacationHours + 20.00)
       END
    )
OUTPUT Deleted.BusinessEntityID, Deleted.VacationHours AS BeforeValue, 
       Inserted.VacationHours AS AfterValue
WHERE SalariedFlag = 0; 

--------------------------------------------------------------------------------------------------------------------
WITH Data (value) AS 
( 
SELECT 0 
UNION ALL 
SELECT 1 
) 
SELECT 
   CASE 
      WHEN MIN(value) <= 0 THEN 0 
      WHEN MAX(1/value) >= 100 THEN 1 
   END 
FROM Data ;

--------------------------------------------------------------------------------------------------------------------
select poh_policynumber as PolicyNumber, Pst_DESCRIPTION_I AS PolicyStatus, Pch_covtype as CoverageType,
Pch_faceamount as Faceamount
--, Pch_effectivedate as EffectiveDate, Pch_TERMINATIONDATE as TerminationDate, 
--Ben_BENTYPE as BenefitType, Ben_amount as BenAmount, BEN_EFFECTIVEDATE AS BenEffectiveDate, 
--Ben_TERMINATIONDATE AS BenTerminationDate, ben_matureexpirydate as BenMaturityDate,  
--Ben_units as Units
, "Price Range" = 
      CASE 
         WHEN Pch_faceamount = 19981000 THEN 'Mfg item - not for resale'
         WHEN Pch_faceamount < 5000000 THEN 'Under $50'
         WHEN Pch_faceamount >= 5000000 and Pch_faceamount < 2500000 THEN 'Under $250'
         WHEN Pch_faceamount >= 2500000 and Pch_faceamount < 1000 THEN 'Under $1000'
         ELSE 'Over $1000'
      END
from cm_opt_poh_policyhdr_s 
inner join Cm_Sys_Pst_PolicyStatus_I on Pst_ID_I= Poh_STATUS
inner join Cm_Opt_Pch_PolicyCovHdr_S on pch_policyhdrid=poh_id
left outer join Cm_Opt_Ben_Benefit_S on Ben_POLICYCOVHDRID = Pch_ID

WHERE Poh_POLICYNUMBER in ('UL')

order by Pch_faceamount;
go
--------------------------------------------------------------------------------------------------------------------