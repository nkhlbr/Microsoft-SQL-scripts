USE MCPSQL;

/* 
	Payout Metrics 
	
	Report: Payout Metrics - Analysis
	
	SQL:	Analysis-Detail_10-1-2014.sql
	
	This query returns the details behind the payout counts the FAST payout contracts by policy status.
	

	----------------------------------------------------------------------------	

	Parameters supplied to the report for RLBL from 7/31/2014.
	
	Modify ARunIdClient, @RunIdSe2, and @goLiveDate to match the data you 
	wish to examine.
	




*/
DECLARE @RunIdClient AS UNIQUEIDENTIFIER  =	'294C58BC-1025-48E2-B88F-B44956816C6B'
DECLARE @RunIdSe2    AS UNIQUEIDENTIFIER  =	'63B754E2-6AB7-4616-BAB9-CDE6DBC6604E'

DECLARE @goLiveDate  AS DATE              = '2015-04-06'
--Don't change any of the following parameters
DECLARE @stsDesc     AS INTEGER          = 1
DECLARE @stsCode     AS INTEGER          = 2
DECLARE @issDate     AS INTEGER          = 3
DECLARE @pmtAmt      AS INTEGER          = 1128
DECLARE @exclAmt     AS INTEGER          = 1129
DECLARE @exclAmtRmn  AS INTEGER          = 1130
DECLARE @exclRatio   AS INTEGER          = 1133
DECLARE @guarPmtRmn  AS INTEGER          = 1131
DECLARE @planCode    AS INTEGER          = 1137
DECLARE @planCat     AS INTEGER          = 1128


DECLARE @fastCycleDate  AS DATE
set @fastCycleDate = (select [cycle_date] from dbo.mtx_run_ids where run_id = @RunIdSe2)

DECLARE @clientCyleDate AS DATE
set @clientCyleDate = (select [cycle_date] from dbo.mtx_run_ids where run_id = @RunIdClient)

/* Check Configured Values */ SELECT @fastCycleDate AS FastCycleDate, @clientCyleDate AS ClientCycleDate, @goLiveDate AS GoLiveDate

SELECT 
	 IGO_NIGO
	,CL_POL_NUM	
	,CL_SEQ_NUM	
	,ONE.PLAN_CAT
    ,CAST(ONE.CL_PC AS INTEGER) AS CL_PC
    ,CAST(ONE.FST_PC AS INTEGER) AS FST_PC

    ,ONE.CL_ISS_DT
    ,ONE.CL_STS

    ,ONE.FST_ISS_DT
    ,ONE.FST_STS
    
	,CL_PMT_AMT	
	,FST_PMT_AMT	
	,DLT_PMT_AMT
	,DLT_PMT_AMT_NC	

	,CL_EXCL_AMT	
	,FST_EXCL_AMT	
	,DLT_EXCL_AMT	

	,CL_EXCL_AMT_RMN	
	,FST_EXCL_AMT_RMN	
	,DLT_EXCL_AMT_RMN	
	
    ,ONE.CL_EXCL_RAT AS CL_EXCL_RAT
    ,ONE.FST_EXCL_RAT AS FST_EXCL_RAT
    ,ABS(ONE.CL_EXCL_RAT - FST_EXCL_RAT) AS DLT_EXCL_RAT
    
    ,ONE.CL_GUAR_PAY_RMN 
    ,ONE.FST_GUAR_PAY_RMN
    
FROM
(
	SELECT  

		/* Active and Terminated are considered IGO; Pending is NIGO. */
		 --  CASE
			--WHEN CAST(CL_ISS_DT.ec_equality_value AS DATE) <= @clientCyleDate AND CL_STS_CD.ec_equality_value = 'IF'    THEN 'IGO'		
			--WHEN CAST(CL_ISS_DT.ec_equality_value AS DATE) <= @clientCyleDate AND CL_STS_CD.ec_equality_value LIKE 'T%' THEN 'IGO'
			--WHEN CAST(CL_ISS_DT.ec_equality_value AS DATE) <= @clientCyleDate AND CL_STS_CD.ec_equality_value LIKE 'P%' THEN 'NIGO'
			--ELSE 'NIGO'
		 --  END AS IGO_NIGO
		 
		   CASE
			WHEN CAST(FST_ISS_DT.ec_equality_value AS DATE) <= @fastCycleDate AND FST_STS_CD.ec_equality_value = 'A' THEN 'IGO'		
			WHEN CAST(FST_ISS_DT.ec_equality_value AS DATE) <= @fastCycleDate AND FST_STS_CD.ec_equality_value = 'T' THEN 'NIGO'
			WHEN CAST(FST_ISS_DT.ec_equality_value AS DATE) <= @fastCycleDate AND FST_STS_CD.ec_equality_value = 'F' THEN 'NIGO'
			ELSE 'NIGO'
		   END AS IGO_NIGO
		 

		   ,CAST(CL_ISS_DT.ec_equality_value AS DATE) AS CL_ISS_DT
           ,CL_STS_CD.ec_equality_value AS CL_STS

		   ,CAST(FST_ISS_DT.ec_equality_value AS DATE) AS FST_ISS_DT
           ,FST_STS_CD.ec_equality_value AS FST_STS
		   
		   ,P.pd_policy_number AS CL_POL_NUM
		   ,PS.ps_seq_num      AS CL_SEQ_NUM
		   
		   ,SE_PLN_CAT.ec_equality_value AS PLAN_CAT
		   
		   ,CL_PMT_AMT.tc_tolerance_value AS CL_PMT_AMT
		   ,CL_EXCL_AMT.tc_tolerance_value AS CL_EXCL_AMT
		   ,CL_EXCL_AMT_RMN.tc_tolerance_value AS CL_EXCL_AMT_RMN
		   
		   ,FST_PMT_AMT.tc_tolerance_value AS FST_PMT_AMT
		   ,FST_EXCL_AMT.tc_tolerance_value AS FST_EXCL_AMT
		   ,FST_EXCL_AMT_RMN.tc_tolerance_value AS FST_EXCL_AMT_RMN
		   
   		   ,COALESCE(CL_PMT_AMT.tc_tolerance_value, 0.0) - COALESCE(FST_PMT_AMT.tc_tolerance_value, 0.0) AS DLT_PMT_AMT
   		   ,CL_PMT_AMT.tc_tolerance_value - FST_PMT_AMT.tc_tolerance_value AS DLT_PMT_AMT_NC
		   ,COALESCE(CL_EXCL_AMT.tc_tolerance_value, 0.0)- COALESCE(FST_EXCL_AMT.tc_tolerance_value, 0.0) AS DLT_EXCL_AMT
		   ,COALESCE(CL_EXCL_AMT_RMN.tc_tolerance_value, 0.0) - COALESCE(FST_EXCL_AMT_RMN.tc_tolerance_value, 0.0) AS DLT_EXCL_AMT_RMN
		   
		   ,CL_EXCL_RAT.tc_tolerance_value AS CL_EXCL_RAT
		   ,FST_EXCL_RAT.tc_tolerance_value AS FST_EXCL_RAT
		   
		   ,CAST(CL_GPR.tc_tolerance_value AS INTEGER) AS CL_GUAR_PAY_RMN
		   ,CAST(FST_GPR.tc_tolerance_value AS INTEGER) AS FST_GUAR_PAY_RMN
		   
		   ,CL_PC.tc_tolerance_value  AS CL_PC
		   ,FST_PC.tc_tolerance_value AS FST_PC
		   
	FROM dbo.mtx_policy_data P

	INNER JOIN dbo.mtx_policy_seq PS ON(PS.ps_policy_number = P.pd_policy_number 
									AND PS.ps_run_id = @RunIdClient)
	/* BEGIN: Client */
	LEFT OUTER JOIN dbo.[mtx_equality_seq_checks] CL_STS_CD ON(CL_STS_CD.ec_run_id = @RunIdClient
												  AND CL_STS_CD.ec_policy_number = P.pd_policy_number
												  AND CL_STS_CD.ec_seq_num = PS.ps_seq_num
												  AND CL_STS_CD.ec_cat_id = @stsCode)
	                                                               
	LEFT OUTER JOIN dbo.[mtx_equality_seq_checks] CL_ISS_DT ON(CL_ISS_DT.ec_run_id = @RunIdClient
												  AND CL_ISS_DT.ec_policy_number = P.pd_policy_number
												  AND CL_ISS_DT.ec_seq_num = PS.ps_seq_num
												  AND CL_ISS_DT.ec_cat_id = @issDate)

	LEFT OUTER JOIN dbo.[mtx_tolerance_seq_checks] CL_PMT_AMT ON(CL_PMT_AMT.tc_run_id = @RunIdClient
												  AND CL_PMT_AMT.tc_policy_number = P.pd_policy_number
												  AND CL_PMT_AMT.tc_seq_num = PS.ps_seq_num
												  AND CL_PMT_AMT.tc_cat_id = @pmtAmt)
	                                                               
	LEFT OUTER JOIN dbo.[mtx_tolerance_seq_checks] CL_EXCL_AMT ON(CL_EXCL_AMT.tc_run_id = @RunIdClient
												  AND CL_EXCL_AMT.tc_policy_number = P.pd_policy_number
												  AND CL_EXCL_AMT.tc_seq_num = PS.ps_seq_num
												  AND CL_EXCL_AMT.tc_cat_id = @exclAmt)
	                                                               
	LEFT OUTER JOIN dbo.[mtx_tolerance_seq_checks] CL_PC ON(CL_PC.tc_run_id = @RunIdClient
												  AND CL_PC.tc_policy_number = P.pd_policy_number
												  AND CL_PC.tc_seq_num = PS.ps_seq_num
												  AND CL_PC.tc_cat_id = @planCode)
	                                                               
	LEFT OUTER JOIN dbo.[mtx_tolerance_seq_checks] CL_EXCL_AMT_RMN ON(CL_EXCL_AMT_RMN.tc_run_id = @RunIdClient
												  AND CL_EXCL_AMT_RMN.tc_policy_number = P.pd_policy_number
												  AND CL_EXCL_AMT_RMN.tc_seq_num = PS.ps_seq_num
												  AND CL_EXCL_AMT_RMN.tc_cat_id = @exclAmtRmn)
	                                                               
	LEFT OUTER JOIN dbo.[mtx_tolerance_seq_checks] CL_EXCL_RAT ON(CL_EXCL_RAT.tc_run_id = @RunIdClient
												  AND CL_EXCL_RAT.tc_policy_number = P.pd_policy_number
												  AND CL_EXCL_RAT.tc_seq_num = PS.ps_seq_num
												  AND CL_EXCL_RAT.tc_cat_id = @exclRatio)

	LEFT OUTER JOIN dbo.[mtx_tolerance_seq_checks] CL_GPR ON(CL_GPR.tc_run_id = @RunIdClient
												  AND CL_GPR.tc_policy_number = P.pd_policy_number
												  AND CL_GPR.tc_seq_num = PS.ps_seq_num
												  AND CL_GPR.tc_cat_id = @guarPmtRmn)
	/* BEGIN: FAST */
	LEFT OUTER JOIN dbo.[mtx_equality_seq_checks] FST_STS_CD ON(FST_STS_CD.ec_run_id = @RunIdSe2
												  AND FST_STS_CD.ec_policy_number = P.pd_policy_number
												  AND FST_STS_CD.ec_seq_num = PS.ps_seq_num
												  AND FST_STS_CD.ec_cat_id = @stsCode)
	                                                               
	LEFT OUTER JOIN dbo.[mtx_equality_seq_checks] FST_ISS_DT ON(FST_ISS_DT.ec_run_id = @RunIdSe2
												  AND FST_ISS_DT.ec_policy_number = P.pd_policy_number
												  AND FST_ISS_DT.ec_seq_num = PS.ps_seq_num
												  AND FST_ISS_DT.ec_cat_id = @issDate)

	--Payout Plan Category
    LEFT OUTER JOIN dbo.[mtx_equality_seq_checks] SE_PLN_CAT 
		ON( SE_PLN_CAT.ec_run_id = @RunIdSe2
		AND SE_PLN_CAT.ec_policy_number = P.pd_policy_number
		AND SE_PLN_CAT.ec_seq_num = PS.ps_seq_num
		AND SE_PLN_CAT.ec_cat_id = @planCat)

	LEFT OUTER JOIN dbo.[mtx_tolerance_seq_checks] FST_PMT_AMT ON(FST_PMT_AMT.tc_run_id = @RunIdSe2
												  AND FST_PMT_AMT.tc_policy_number = P.pd_policy_number
												  AND FST_PMT_AMT.tc_seq_num = PS.ps_seq_num
												  AND FST_PMT_AMT.tc_cat_id = @pmtAmt)
	                                                               
	LEFT OUTER JOIN dbo.[mtx_tolerance_seq_checks] FST_EXCL_AMT ON(FST_EXCL_AMT.tc_run_id = @RunIdSe2
												  AND FST_EXCL_AMT.tc_policy_number = P.pd_policy_number
												  AND FST_EXCL_AMT.tc_seq_num = PS.ps_seq_num
												  AND FST_EXCL_AMT.tc_cat_id = @exclAmt)
	                                                               
	LEFT OUTER JOIN dbo.[mtx_tolerance_seq_checks] FST_PC ON(FST_PC.tc_run_id = @RunIdSe2
												  AND FST_PC.tc_policy_number = P.pd_policy_number
												  AND FST_PC.tc_seq_num = PS.ps_seq_num
												  AND FST_PC.tc_cat_id = @planCode)
	                                                               
	LEFT OUTER JOIN dbo.[mtx_tolerance_seq_checks] FST_EXCL_AMT_RMN ON(FST_EXCL_AMT_RMN.tc_run_id = @RunIdSe2
												  AND FST_EXCL_AMT_RMN.tc_policy_number = P.pd_policy_number
												  AND FST_EXCL_AMT_RMN.tc_seq_num = PS.ps_seq_num
												  AND FST_EXCL_AMT_RMN.tc_cat_id = @exclAmtRmn)
	                                                               
	LEFT OUTER JOIN dbo.[mtx_tolerance_seq_checks] FST_EXCL_RAT ON(FST_EXCL_RAT.tc_run_id = @RunIdSe2
												  AND FST_EXCL_RAT.tc_policy_number = P.pd_policy_number
												  AND FST_EXCL_RAT.tc_seq_num = PS.ps_seq_num
												  AND FST_EXCL_RAT.tc_cat_id = @exclRatio)

	LEFT OUTER JOIN dbo.[mtx_tolerance_seq_checks] FST_GPR ON(FST_GPR.tc_run_id = @RunIdSe2
												  AND FST_GPR.tc_policy_number = P.pd_policy_number
												  AND FST_GPR.tc_seq_num = PS.ps_seq_num
												  AND FST_GPR.tc_cat_id = @guarPmtRmn)
	WHERE P.pd_run_id = @RunIdClient
	
) ONE

ORDER BY IGO_NIGO, CL_POL_NUM, CL_SEQ_NUM	
