






declare @table varchar(32);
set @table = '#ProposedData';

select
    CONCAT
    (
    'Insert into ' 
    , @table 
    , ' values (' 
    , '''', policy_number, '''' 
    , ',' , CONVERT(DECIMAL(10, 2), PROPOSED_GLP)
    , ',' , CONVERT(DECIMAL(10, 2), PROPOSED_GSP)
    , ',' , CONVERT(DECIMAL(10, 2), PROPOSED_CUM_PREM_AMT)
    , ',' , CONVERT(DECIMAL(10, 2), PROPOSED_CUM_WTHLD_AMT)
    , ',' , CASE WHEN DATEADD(YEAR, 7, SEVEN_PAY_START_DATE) < @ConversionDate THEN CONVERT(DECIMAL(10, 2), PROPOSED_7_PAY_LIMIT)
            ELSE 0
            END
    , ',' , CONVERT(DECIMAL(10, 2), PROPOSED_CUM_GLP)
    , ',' , CONVERT(DECIMAL(10, 2), RIBTestPremium)
    , ',' , 'NULL' -- 'TODO' as MP_NLG_END_DT
    , ',' , 'NULL' -- 'TODO' as MP_MNTHLY_NLG
    , ',' , 'NULL' -- 'TODO' as MP_CUM_NLG
    , ',' , '''', SEVEN_PAY_START_DATE, ''''
    , ',' , CONVERT(DECIMAL(10, 2), SPA_SevenPayAnn)
    , ',' , 'NULL' -- 'TOOD' as TCPR_TAMRA_CUM_PREM
    , ',' , 'NULL' -- 'TODO' as BASE_GLP
    , ',' , 'NULL' -- 'TODO' as BASE_GSP
    , ');' 
    ) as SQL_Text
from 
    #ProposedData
order
    by policy_number
;

select * from Cm_Opt_Cba_ConvBenefitAdj_S





IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='GLEntry' AND xtype='U')