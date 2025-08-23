

DECLARE @sqlCreateUser nvarchar(500),
        @database_name AS nvarchar(128),
        @i smallint,
        @minid smallint,
        @maxid smallint,
        @sqldb varchar(500),
        @chvnSQL1 nvarchar(max),
        @chvnSQL2 nvarchar(max),
        @chvnSQL3 nvarchar(max),
        @chvnSQL4 nvarchar(max),
        @sqldb_Input varchar(100),
        @inttUsr1Cnt tinyint,
        @inttUsr2Cnt tinyint,
        @inttUsr3Cnt tinyint,
        @inttUsr4Cnt tinyint,
        @ParmDefinition nvarchar(500);

SET @minid = 5
SET @i = @minid

SELECT
@maxid = MAX(database_id)
FROM sys.databases

WHILE @i <= @maxid
BEGIN
IF NOT EXISTS (SELECT
                       *
                     FROM sys.databases
                     WHERE database_id = @i
                     AND name = 'se2dba')
  BEGIN

    SELECT
      @sqldb_input = name
    FROM sys.databases
    WHERE database_id = @i

    PRINT @sqldb_input;

    SET @chvnSQL1 = 'USE ' + '[' + @sqldb_Input + '];' + 'SELECT @inttUsr1Cnt_Output = COUNT(*) FROM sys.sysusers WHERE name LIKE ' + '''SBGLAN1\SQL_FAST_DEV_DLIC_READ'''
    PRINT @chvnSQL1
    SET @ParmDefinition = N'@inttUsr1Cnt_Output tinyint OUTPUT';
    EXECUTE sp_executesql @chvnSQL1,
                          @ParmDefinition,
                          @inttUsr1Cnt_Output = @inttUsr1Cnt OUTPUT;
    IF (@inttUsr1Cnt = 0)
    BEGIN
      SELECT
        @sqlCreateUser = 'use [' + name + '];' + 'CREATE USER [SBGLAN1\SQL_FAST_DEV_DLIC_READ] FROM LOGIN [SBGLAN1\SQL_FAST_DEV_DLIC_READ];' + 'exec sp_addrolemember [db_datareader], [SBGLAN1\SQL_FAST_DEV_DLIC_READ];' --+ CHAR(13) + 'GO'
      FROM sys.databases
      WHERE database_id = @i

       EXECUTE(@sqlCreateUser);
    END
    
     SET @chvnSQL2 = 'USE ' + '[' + @sqldb_Input + '];' + 'SELECT @inttUsr2Cnt_Output = COUNT(*) FROM sys.sysusers WHERE name LIKE ' + '''SBGLAN1\SQL_FAST_DEV_READ'''
    PRINT @chvnSQL2
    SET @ParmDefinition = N'@inttUsr2Cnt_Output tinyint OUTPUT';
    EXECUTE sp_executesql @chvnSQL2,
                          @ParmDefinition,
                          @inttUsr2Cnt_Output = @inttUsr2Cnt OUTPUT;
    IF (@inttUsr2Cnt = 0)
    BEGIN
      SELECT
        @sqlCreateUser = 'use [' + name + '];' + 'CREATE USER [SBGLAN1\SQL_FAST_DEV_READ] FROM LOGIN [SBGLAN1\SQL_FAST_DEV_READ];' + 'exec sp_addrolemember [db_datareader], [SBGLAN1\SQL_FAST_DEV_READ];' --+ CHAR(13) + 'GO'
      FROM sys.databases
      WHERE database_id = @i

       EXECUTE(@sqlCreateUser);
    END

     SET @chvnSQL3 = 'USE ' + '[' + @sqldb_Input + '];' + 'SELECT @inttUsr3Cnt_Output = COUNT(*) FROM sys.sysusers WHERE name LIKE ' + '''SBGLAN1\SQL_FAST_DEV_DBO'''
    PRINT @chvnSQL3
    SET @ParmDefinition = N'@inttUsr3Cnt_Output tinyint OUTPUT';
    EXECUTE sp_executesql @chvnSQL3,
                          @ParmDefinition,
                          @inttUsr3Cnt_Output = @inttUsr3Cnt OUTPUT;
    IF (@inttUsr3Cnt = 0)
    BEGIN
      SELECT
        @sqlCreateUser = 'use [' + name + '];' + 'CREATE USER [SBGLAN1\SQL_FAST_DEV_DBO] FROM LOGIN [SBGLAN1\SQL_FAST_DEV_DBO];' + 'exec sp_addrolemember [db_datareader], [SBGLAN1\SQL_FAST_DEV_DBO];' --+ CHAR(13) + 'GO'
      FROM sys.databases
      WHERE database_id = @i

       EXECUTE(@sqlCreateUser);

    END
        
     SET @chvnSQL4 = 'USE ' + '[' + @sqldb_Input + '];' + 'SELECT @inttUsr4Cnt_Output = COUNT(*) FROM sys.sysusers WHERE name LIKE ' + '''SBGLAN1\SQL_FAST_DEV_DLIC_DBO'''
    PRINT @chvnSQL4
    SET @ParmDefinition = N'@inttUsr4Cnt_Output tinyint OUTPUT';

    EXECUTE sp_executesql @chvnSQL4,
                          @ParmDefinition,
                          @inttUsr4Cnt_Output = @inttUsr4Cnt OUTPUT;

    IF (@inttUsr4Cnt = 0)
    BEGIN
      SELECT
        @sqlCreateUser = 'use [' + name + '];' + 'CREATE USER [SBGLAN1\SQL_FAST_DEV_DLIC_DBO] FROM LOGIN [SBGLAN1\SQL_FAST_DEV_DLIC_DBO];' + 'exec sp_addrolemember [db_datareader], [SBGLAN1\SQL_FAST_DEV_DLIC_DBO];' --+ CHAR(13) + 'GO'
      FROM sys.databases
      WHERE database_id = @i

       EXECUTE(@sqlCreateUser);

    END
  END

  SET @i += 1

END
