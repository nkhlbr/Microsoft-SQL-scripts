
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WriteToFile]
 
@File        VARCHAR(2000),
@Text        VARCHAR(2000)
 
AS 
 
BEGIN 
 
DECLARE @OLE            INT 
DECLARE @FileID         INT 
 
 
EXECUTE sp_OACreate 'Scripting.FileSystemObject', @OLE OUT 
       
EXECUTE sp_OAMethod @OLE, 'OpenTextFile', @FileID OUT, @File, 8, 1 
     
EXECUTE sp_OAMethod @FileID, 'WriteLine', Null, @Text
 
EXECUTE sp_OADestroy @FileID 
EXECUTE sp_OADestroy @OLE 
 
END 


EXEC WriteToFile '\\sbgcommon\SYS\DEPTS\SE2\FAST\FASTDeliverablesBase\StartingPoint\New folder\Log.txt','Did it work?' 