



DECLARE @isExists INT
exec master.dbo.xp_fileexist '\\sbgcommon\SYS\DEPTS\SE2\FAST\FASTDeliverablesBase\StartingPoint\StartingPointDatabase.bak', 
@isExists OUTPUT
SELECT case @isExists 
when 1 then 'True' 
else 'False' 
end as isExists