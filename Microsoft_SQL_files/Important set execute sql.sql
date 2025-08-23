

set ansi_nulls on
go 

set quoted_identifier on
go

if exists (select name 
from sys.objects where object_id = object_ID(N'[dbo].[uspRefreshTables]'))


drop procedure [dbo].[uspRefreshTables];
go

create procedure [dbo].[uspRefreshTables]

           @chvnSourceServerName NVARCHAR(100),
           @chvnSourceDatabaseName NVARCHAR(100),
           @chvnDestinationServerName NVARCHAR(100),
           @chvnDestinationDatabaseName NVARCHAR(100),
           @chvnTableNames NVARCHAR(MAX)

		   as

		   begin 

		   set nocount on;


		DECLARE @chvnNoCheckConstSQL NVARCHAR(MAX);
        DECLARE @chvnDeleteStmt NVARCHAR(MAX);
        DECLARE @chvnColumnsListStmt NVARCHAR(MAX);
        DECLARE @chvnColumnList NVARCHAR(MAX);
        DECLARE @chvnInsertStmt NVARCHAR(MAX);
        DECLARE @chvnTableName NVARCHAR(500);
        DECLARE @intTablesCount INT;
		DECLARE @intInit INT =1;

if OBJECT_ID('tempdb..#RefreshTables') IS NOT NULL
BEGIN 
       DROP TABLE #RefreshTables
END 

CREATE TABLE #RefreshTables (TABLEID INT IDENTITY(1,1) NOT NULL, TABLENAME VARCHAR(500))

INSERT INTO #RefreshTables (TABLENAME) SELECT ITEM FROM dbo.fnSplit ((@CHVNTABLENAMES), ',')

SELECT @intTablesCount = COUNT(*) FROM  #RefreshTables


SET @chvnNoCheckConstSQL = 'BEGIN EXEC' + ' ' + QUOTENAME(@chvnDestinationServerName) + '.' + QUOTENAME(@chvnDestinationDatabaseName) + '.[dbo].sp_msforeachtable " ALTER TABLE ? NOCHECK CONSTRAINT all"  END'

execute sp_executesql @chvnNoCheckConstSQL




sp_executesql (Transact-SQL)

Other Versions 
 
THIS TOPIC APPLIES TO: yesSQL Server (starting with 2008)yesAzure SQL DatabaseyesAzure SQL Data Warehouse yesParallel Data Warehouse
Executes a Transact-SQL statement or batch that can be reused many times, or one that has been built dynamically. The Transact-SQL statement or batch can contain embedded parameters.
System_CAPS_ICON_important.jpg Important

Run time-compiled Transact-SQL statements can expose applications to malicious attacks.
Topic link icon Transact-SQL Syntax Conventions
Syntax
-- Syntax for SQL Server, Azure SQL Database, Azure SQL Data Warehouse, Parallel Data Warehouse  
  
sp_executesql [ @stmt = ] statement  
[   
  { , [ @params = ] N'@parameter_name data_type [ OUT | OUTPUT ][ ,...n ]' }   
     { , [ @param1 = ] 'value1' [ ,...n ] }  
]  

Arguments
[ @stmt= ] statement
Is a Unicode string that contains a Transact-SQL statement or batch. @stmt must be either a Unicode constant or a Unicode variable. More complex Unicode expressions, such as concatenating two strings with the + operator, are not allowed. Character constants are not allowed. If a Unicode constant is specified, it must be prefixed with an N. For example, the Unicode constant N'sp_who' is valid, but the character constant 'sp_who' is not. The size of the string is limited only by available database server memory. On 64-bit servers, the size of the string is limited to 2 GB, the maximum size of nvarchar(max).
System_CAPS_ICON_note.jpg Note

@stmt can contain parameters having the same form as a variable name, for example: N'SELECT * FROM HumanResources.Employee WHERE EmployeeID = @IDParameter'
Each parameter included in @stmt must have a corresponding entry in both the @params parameter definition list and the parameter values list.
[ @params= ] N'@parameter_namedata_type [ ,... n ] '
Is one string that contains the definitions of all parameters that have been embedded in @stmt. The string must be either a Unicode constant or a Unicode variable. Each parameter definition consists of a parameter name and a data type. n is a placeholder that indicates additional parameter definitions. Every parameter specified in @stmtmust be defined in @params. If the Transact-SQL statement or batch in @stmt does not contain parameters, @params is not required. The default value for this parameter is NULL.
[ @param1= ] 'value1'
Is a value for the first parameter that is defined in the parameter string. The value can be a Unicode constant or a Unicode variable. There must be a parameter value supplied for every parameter included in @stmt. The values are not required when the Transact-SQL statement or batch in @stmt has no parameters.
[ OUT | OUTPUT ]
Indicates that the parameter is an output parameter. text, ntext, and image parameters can be used as OUTPUT parameters, unless the procedure is a common language runtime (CLR) procedure. An output parameter that uses the OUTPUT keyword can be a cursor placeholder, unless the procedure is a CLR procedure.
n
Is a placeholder for the values of additional parameters. Values can only be constants or variables. Values cannot be more complex expressions such as functions, or expressions built by using operators.
Return Code Values
0 (success) or non-zero (failure)
Result Sets
Returns the result sets from all the SQL statements built into the SQL string.
Remarks
sp_executesql parameters must be entered in the specific order as described in the "Syntax" section earlier in this topic. If the parameters are entered out of order, an error message will occur.
sp_executesql has the same behavior as EXECUTE with regard to batches, the scope of names, and database context. The Transact-SQL statement or batch in the sp_executesql @stmt parameter is not compiled until the sp_executesql statement is executed. The contents of @stmt are then compiled and executed as an execution plan separate from the execution plan of the batch that called sp_executesql. The sp_executesql batch cannot reference variables declared in the batch that calls sp_executesql. Local cursors or variables in the sp_executesql batch are not visible to the batch that calls sp_executesql. Changes in database context last only to the end of the sp_executesql statement.
sp_executesql can be used instead of stored procedures to execute a Transact-SQL statement many times when the change in parameter values to the statement is the only variation. Because the Transact-SQL statement itself remains constant and only the parameter values change, the SQL Server query optimizer is likely to reuse the execution plan it generates for the first execution.
System_CAPS_ICON_note.jpg Note

To improve performance use fully qualified object names in the statement string.
sp_executesql supports the setting of parameter values separately from the Transact-SQL string as shown in the following example.
DECLARE @IntVariable int;  
DECLARE @SQLString nvarchar(500);  
DECLARE @ParmDefinition nvarchar(500);  
  
/* Build the SQL string one time.*/  
SET @SQLString =  
     N'SELECT BusinessEntityID, NationalIDNumber, JobTitle, LoginID  
       FROM AdventureWorks2012.HumanResources.Employee   
       WHERE BusinessEntityID = @BusinessEntityID';  
SET @ParmDefinition = N'@BusinessEntityID tinyint';  
/* Execute the string with the first parameter value. */  
SET @IntVariable = 197;  
EXECUTE sp_executesql @SQLString, @ParmDefinition,  
                      @BusinessEntityID = @IntVariable;  
/* Execute the same string with the second parameter value. */  
SET @IntVariable = 109;  
EXECUTE sp_executesql @SQLString, @ParmDefinition,  
                      @BusinessEntityID = @IntVariable;  

Output parameters can also be used with sp_executesql. The following example retrieves a job title from the AdventureWorks2012.HumanResources.Employee table and returns it in the output parameter @max_title.
DECLARE @IntVariable int;  
DECLARE @SQLString nvarchar(500);  
DECLARE @ParmDefinition nvarchar(500);  
DECLARE @max_title varchar(30);  
  
SET @IntVariable = 197;  
SET @SQLString = N'SELECT @max_titleOUT = max(JobTitle)   
   FROM AdventureWorks2012.HumanResources.Employee  
   WHERE BusinessEntityID = @level';  
SET @ParmDefinition = N'@level tinyint, @max_titleOUT varchar(30) OUTPUT';  
  
EXECUTE sp_executesql @SQLString, @ParmDefinition, @level = @IntVariable, @max_titleOUT=@max_title OUTPUT;  
SELECT @max_title;  
