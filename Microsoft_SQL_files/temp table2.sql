









if exists (
	select
		* 
	from
		#temp
) then  delete table #temp;  
end if;    create table #temp

if exists (
    select  * from tempdb.dbo.sysobjects o
    where o.xtype in ('U')  

   and o.id = object_id(N'tempdb..#tempTable')
)
create table #temp;

IF OBJECT_ID('tempdb..#CommutationDL') IS NOT NULL 
BEGIN 
        DROP TABLE #CommutationDL 
END




IF EXISTS (
SELECT *
FROM sys.tables
WHERE name LIKE '#temp%')
DROP TABLE #TEMPTBL1