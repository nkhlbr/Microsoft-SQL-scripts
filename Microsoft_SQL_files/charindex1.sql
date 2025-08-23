select cast(cast(a.Fst_EXTERNALCODE as varchar) + right('           ',11-len(cast(a.Fst_EXTERNALCODE as varchar))) as varchar) as Fst_EXTERNALCODE
,a.Fst_MANDE,a.Fuv_ID,a.fuv_FUNDSTREAMID 
from 
(select  substring (Fst_EXTERNALCODE,1, CHARINDEX('-', Fst_EXTERNALCODE)-1) as Fst_EXTERNALCODE 
,CAST((fst_mande* 10000000) as varchar) as Fst_MANDE,newid() as Fuv_ID,Fst_ID as fuv_FUNDSTREAMID 
from Cm_Opt_Fst_FundStream_S
where Fst_EXTERNALCODE like '%-%'

union

select  Fst_EXTERNALCODE as Fst_EXTERNALCODE 
,CAST((fst_mande* 10000000) as varchar) as Fst_MANDE,newid() as Fuv_ID,Fst_ID as fuv_FUNDSTREAMID 
from Cm_Opt_Fst_FundStream_S
where Fst_EXTERNALCODE not like '%-%') a


select CAST((fst_mande* 10000000) as varchar) as Fst_MANDE ,CHARINDEX('-', Fst_EXTERNALCODE)-1 from Cm_Opt_Fst_FundStream_S
select Fst_NAME, right(Fst_NAME,5), 133-len(Fst_NAME), right('           ',25-len(cast(Fst_EXTERNALCODE as varchar))) as Fst_EXTERNAL, Fst_EXTERNALCODE  from Cm_Opt_Fst_FundStream_S
select substring (Fst_EXTERNALCODE,1, CHARINDEX('-', Fst_EXTERNALCODE)-1) as Fst_EXTERNALCODE from Cm_Opt_Fst_FundStream_S where Fst_EXTERNALCODE like '%-%'


SELECT SUBSTRING(Fst_EXTERNALCODE, 0, CHARINDEX('-', Fst_EXTERNALCODE))  AS whole_val, Fst_EXTERNALCODE
FROM dbo.Cm_Opt_Fst_FundStream_S 


select Fst_EXTERNALCODE, substring(Fst_EXTERNALCODE,1, CHARINDEX('-', Fst_EXTERNALCODE)-1), CHARINDEX('-', Fst_EXTERNALCODE) from Cm_Opt_Fst_FundStream_S where Fst_EXTERNALCODE  like '%-%'