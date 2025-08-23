
--–Execute below code on Source Server Master Database

--–Parameters

DECLARE @sourceDatabase nvarchar(100),

        @backUpFileLocation nvarchar(100)

--–T-SQL to perform backup

DECLARE @sql nvarchar(max),

        @backUpFileName nvarchar(500)

SELECT @backUpFileName = @sourceDatabase + '_todayrelease.bak'  --preparing backup file name

SET @sql =

'BACKUP DATABASE [' +  @sourceDatabase + ']

TO DISK=N”'+ @backUpFileLocation + @backUpFileName +”'

WITH NOFORMAT

,NOINIT,SKIP,NOREWIND,NOUNLOAD'

EXEC SP_EXECUTESQL @sql

--Till this point, our backup is done and .bak file will be placed at backup file location specified in parameters.

--Now it's time to restore the back up. Here goes the code:

--–Execute below code on Destination Server Master Database

--–Parameters

DECLARE @DestinationDatabase nvarchar(100),

        @backupfilelocation nvarchar(100), --same as specified while taking backup

        @sourcemdffile nvarchar(100),

        @sourceldffile nvarchar(100),

        @backupfilename nvarchar(100),     --same as specified while taking backup

        @destinationMDFfile nvarchar(100),

        @destinationLDFfile nvarchar(100)

--T-SQL code to perform Restore operation

DECLARE @targetDB nvarchar(100),

@sql nvarchar(max)

SELECT @targetDB = @DestinationDatabase

SELECT @sql = 'RESTORE DATABASE [' + @targetDB +'] FROM DISK = N"' + @backupfilelocation + @backupfilename + '" WITH FILE= 1

,MOVE "' + @sourcemdffile + "' TO '" + @destinationMDFfile + '\'+@targetDB +'.MDF"

,MOVE "' + @destinationMDFfile + "' TO '" + @destinationLDFfile + '\' +@targetDB +'_1.LDF"

,NOUNLOAD'

EXECUTE SP_EXECUTESQL @SQL