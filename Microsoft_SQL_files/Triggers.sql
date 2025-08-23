




\*
CREATE TRIGGER dbo.-----
ON dbo.-------
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (CONDITION)
    BEGIN
        EXEC msdb.dbo.sp_send_dbmail
          @recipients = '@se2.com', 
          --@profile_name = '',
          @subject = '-------', 
          @body = '--------';
    END
END
GO

select * from dbo.sp_send_dbmail


GRANT INSERT, UPDATE, DELETE ON [dbo].[SP500IndexTable] TO [SBGLAN1\BARUA]
DENY INSERT, UPDATE, DELETE ON [dbo].[SP500IndexTable] TO [SBGLAN1\BARUA]


CREATE TRIGGER trReadOnly_cm_opt_Ect_ExternalContract_S  ON cm_opt_Ect_ExternalContract_S 
    INSTEAD OF INSERT,
               UPDATE,
               DELETE
AS
BEGIN
    RAISERROR( 'cm_opt_Ect_ExternalContract_S  table is read only.', 16, 1 )
    ROLLBACK TRANSACTION
END

disable trigger trReadOnly_tblEvents on tblevents

ALTER TABLE tblEvents WITH NOCHECK ADD CONSTRAINT chk_read_only_tblEvent CHECK( 1 = 0 )


BEGIN    

RAISERROR( '[SP500IndexTable] table is read only.', 17, 1 )    

ROLLBACK TRANSACTIONEND


create 

TRY
BEGIN
    insert......
END
CATCH
BEGIN
RAISERROR( '[SP500IndexTable] table is read only.', 17, 1 )     
ROLLBACK TRANSACTIONEND
END
*/  
  
Alter TRIGGER trReadOnly_cm_opt_Ect_ExternalContract_S  ON cm_opt_Ect_ExternalContract_S 
    INSTEAD OF INSERT,
               UPDATE,
               DELETE
AS
BEGIN
    RAISERROR( 'cm_opt_Ect_ExternalContract_S  table is read only.', 16, 1 )
    ROLLBACK TRANSACTION
END

BEGIN TRY
  SELECT 17, 1,@@ERROR;
END TRY
 BEGIN CATCH
EXECUTE trReadOnly_cm_opt_Ect_ExternalContract_S;
END CATCH;
  

[dbo].[Cm_Opt_Ect_ExternalContract_S]
  




--truncate table [dbo].[Cm_Opt_Ect_ExternalContract_S]

--set identity_insert [dbo].[Cm_Opt_Ect_ExternalContract_S] on;

INSERT INTO [dbo].[Cm_Opt_Ect_ExternalContract_S]
           ([Ect_ID]
           ,[Ect_EXTERNALCONTRACTID]
           ,[Ect_NAME]
           ,[Ect_TAXID]
           ,[Ect_ADDRESS]
           ,[Ect_PHONENUMBERS]
           ,[Ect_SERVICING]
           ,[Ect_LASTCONTACTDATE]
           ,[Ect_HIERARCHYINFO]
           ,[Ect_WHOLESALER]
           ,[Ect_USERID]
           ,[Ect_TIMESTAMP])
  
SELECT [Ect_ID]
      ,[Ect_EXTERNALCONTRACTID]
      ,[Ect_NAME]
      ,[Ect_TAXID]
      ,[Ect_ADDRESS]
      ,[Ect_PHONENUMBERS]
      ,[Ect_SERVICING]
      ,[Ect_LASTCONTACTDATE]
      ,[Ect_HIERARCHYINFO]
      ,[Ect_WHOLESALER]
      ,[Ect_USERID]
      ,[Ect_TIMESTAMP]
  FROM  [FASTPROD].[Se2Fast].[dbo].[Cm_Opt_Ect_ExternalContract_S]

  --set identity_insert [dbo].[Cm_Opt_Ect_ExternalContract_S] off;

    select * from [dbo].[Cm_Opt_Ect_ExternalContract_S]



DECLARE @myint int;
SET @myint = 'ABC';
go
SELECT 'Error number was: ', @@ERROR; 



DECLARE @myint int; 
SET @myint = 1; 
GO 


SELECT 'Error number was: ', @@ERROR; 

DECLARE @ErrorVar INT;
DECLARE @RowCountVar INT;

DELETE FROM HumanResources.JobCandidate
  WHERE JobCandidateID = 13;
-- Save @@ERROR and @@ROWCOUNT while they are both
-- still valid.
SELECT @ErrorVar = @@ERROR,
    @RowCountVar = @@ROWCOUNT;
IF (@ErrorVar <> 0)
    PRINT N'Error = ' + CAST(@ErrorVar AS NVARCHAR(8));
PRINT N'Rows Deleted = ' + CAST(@RowCountVar AS NVARCHAR(8));
GO







IF EXISTS(SELECT name FROM sys.objects
          WHERE name = N'SampleProcedure')
    DROP PROCEDURE SampleProcedure;
GO
-- Create a procedure that takes one input parameter
-- and returns one output parameter and a return code.
CREATE PROCEDURE SampleProcedure @ID INT,
    @SP500IndexValue varchar OUTPUT
AS

    -- Declare and initialize a variable to hold @@ERROR.
    DECLARE @ErrorSave1 INT, @ErrorSave2 INT;
    SET @ErrorSave1 = 0;

    -- Do a SELECT using the input parameter.
    SELECT ID,  TempCalcValuesEffectiveDate, SP500IndexValue 
        FROM dbo.SP500IndexTable
        WHERE ID = @ID;

    -- Save @@ERROR value in first local variable.
    SET @ErrorSave1 = @@ERROR;

    -- Set a value in the output parameter.
    SELECT @SP500IndexValue =  MAX(SP500IndexValue)
        FROM dbo.SP500IndexTable;

    -- Save @@ERROR value in second local variable. 
    SET @ErrorSave2 = @@ERROR;
    -- If second test variable contains non-zero value, 
    -- overwrite value in first local variable.
    IF (@ErrorSave2 <> 0) SET @ErrorSave1 = @ErrorSave2;

    -- Returns 0 if neither SELECT statement had
    -- an error; otherwise, returns the last error.
    RETURN @ErrorSave1;
GO
    
DECLARE @OutputParm varchar;
DECLARE @ReturnCode INT;

EXEC @ReturnCode = SampleProcedure 13, @OutputParm OUTPUT;

PRINT N'OutputParm = @OutputParm '; --+ CAST(@OutputParm AS NVARCHAR(20));
PRINT N'ReturnCode = ' + CAST(@ReturnCode AS NVARCHAR(20));
GO


select * from SP500IndexTable
truncate table dbo.SP500IndexTable

set identity_insert dbo.SP500IndexTable on;
INSERT INTO [dbo].[SP500IndexTable]
           ([ID],
		   [DT_PRIORITY]
           ,[TempCalcValuesEffectiveDate]
           ,[SP500IndexValue])
 SELECT [ID]
       ,[DT_PRIORITY]
       ,[TempCalcValuesEffectiveDate]
       ,[SP500IndexValue]
FROM FASTPROD.[Se2Fast].[dbo].[SP500IndexTable]

  set identity_insert dbo.SP500IndexTable off;

  Cm_Opt_Qrs_QuoteRes_S


  select DATEADD(dd, DATEDIFF(dd, 0, GETDATE()),0)
  select DATEADD(dd, DATEDIFF(dd, 1, GETDATE()),0)