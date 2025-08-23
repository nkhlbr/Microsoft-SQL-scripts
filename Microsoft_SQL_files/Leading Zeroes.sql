





select SYSDATETIME()



create function dbo.fnsplit

(@sInputList varchar (8000)
,@sdelimiter Varchar(8000) = ',')

returns @list Table (item vrchar(8000)


begin 
declare @sitem varchar(8000)
while CHARINDEX(@sdelimiter, @sInputList,0) <> 0





create table num_table

(id int not null primary key identity(1,1)
,num int
,leading_zeros smallint,
constraint chk_leading_zero_nonnegative check (leading_zero>=0),
num_formatted as replicate('0',coalesce(leading_zeros,0)) +cast(num as varchar(10)));
insert into num_table(num,leading_zeros) values(23,2) ;
select num_formatted from num_table; -- output '0023'




select cast(ordernumber as varchar(10)) + '00' from yourtable

DECLARE @sItem decimal
set @sItem = 3/2

select @sItem RIGHT('0'+ CONVERT(VARCHAR, CAST(ROUND(@sItem,3,0) AS DECIMAL (9,3))), 6)



