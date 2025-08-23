


SELECT DISTINCT FST_CODE, Fir_EFFECTIVEDATE, Fir_INTERESTRATE, FST.Fst_ID
FROM dbo.Cm_Opt_Fst_FundStream_S FST
INNER JOIN (SELECT fir1.* 
				 FROM dbo.Cm_Opt_Fir_FundInterestRate_S fir1 
				WHERE fir1.Fir_EFFECTIVEDATE = (SELECT MAX(firx.Fir_EFFECTIVEDATE) 
											 FROM dbo.Cm_Opt_Fir_FundInterestRate_S firx
											WHERE fir1.Fir_FUNDSTREAMID = firx.Fir_FUNDSTREAMID )
			   ) FIR ON fir.Fir_FUNDSTREAMID = fst.Fst_ID




restore database se2fast_bl1

from disk = N'Z:\jdijdiejie\'.bak
with file = 6
norecovery;

restore database se2fast_bl
from disk 'z:\\'
with file = 7, nounload, stats = 5


alter database se2fast
set recovery simple with no_wait

alter database se2fast 
set compatibility_level = 120

alter database se2fast
set multi_user

set nocountoff


select a.name, b.name as 'Logical filename', b.filename from sysdatabases a 
inner join sysaltfiles b on a.dbid = b.dbid where fileid in (1,2) 


select * from sysaltfiles


"DELETE FROM Cm_JON_POLICYHDR_Qrs_S WHERE Poh_QUOTERESID in (
SELECT Qrs_ID FROm Cm_Opt_Qrs_QuoteRes_S WHERE Qrs_QuoteDate < DATEAdd(DAY,-2,GETDATE())
)"
"DELETE FROM Cm_Opt_Qfr_QuoteFundRes_S WHERE Qfr_QUoteResID in (
SELECT Qrs_ID FROm Cm_Opt_Qrs_QuoteRes_S WHERE Qrs_QuoteDate < DATEAdd(DAY,-2,GETDATE())
)"
DELETE FROM  Cm_Opt_Qrs_QuoteRes_S WHERE Qrs_QuoteDate < DATEAdd(DAY,-2,GETDATE())
