/***************************************************************************************************
Author			:	
Version			:	1.1
Date			:	
Description		:	Configure Change Data Capture for a database table.
	
Modifications	:
MM.DD.YYYY	Who		Comment


Resources	:

***************************************************************************************************/

--Create CDCTables filegroup
	alter database [SE2WebMartStaging2]
		add filegroup SE2WebMartStagingCDCTables;

	
	--Add file to filegroup
	alter database SE2WebMartStaging2
		add file
		(
			name = SE2WebMartStaging_CDCHistoryData,
			filename = 'F:\SQLData_SE2WebMartStaging2\Files\SE2WebMartStaging2_CDCHistoryData.ndf',
			size = 5MB,
			--maxsize = ,
			filegrowth = 100MB
		)
		to filegroup SE2WebMartStagingCDCTables;
		

--Enable CDC at the database level
	exec sp_cdc_enable_db;
GO
	
--Enable CDC for the table (record each data manipulation language (DML) operation)
	exec sp_cdc_enable_table 
		@source_schema=N'dbo'
		,@source_name = N'DT_DataProcess'
		,@role_name = N'CDC_Access'	--this gets created if it does not already exist
		--,@supports_net_changes = 1	--default is 1 if PK exists
		,@filegroup_name=N'SE2WebMartStagingCDCTables';
GO

	--Enable CDC for the table (record each data manipulation language (DML) operation)
	exec sp_cdc_enable_table 
		@source_schema=N'dbo'
		,@source_name = N'DT_MasterProcess'
		,@role_name = N'CDC_Access'	--this gets created if it does not already exist
		--,@supports_net_changes = 1	--default is 1 if PK exists
		,@filegroup_name=N'SE2WebMartStagingCDCTables';
GO


	--************************************
	--Retention
	--Default is 3 days (4320 minutes)
	--************************************
	sp_cdc_change_job @job_type='cleanup', 
					@retention=43200	--Number of minutes that change rows are to be retained in change tables. retention is bigint with a default of NULL,
									--which indicates no change for this parameter. The maximum value is 52494800 (100 years). If specified, the value
									--must be a positive integer. retention is valid only for cleanup jobs.

--Verify CDC config
	EXECUTE sys.sp_cdc_help_change_data_capture 
	    @source_schema = N'dbo', 
	    @source_name = N'DT_DataProcess';
	
	select is_cdc_enabled, name
	from sys.databases 
	where is_cdc_enabled = 1;
	  
	select is_tracked_by_cdc, name
	from sys.tables 
	where is_tracked_by_cdc = 1;
	
	
	select * from msdb.dbo.cdc_jobs
	

--********************************************************
--Store data into history table for "permanent" retention
--********************************************************
	create table dbo.DT_DataProcess_CDC_history
	(
	--custom column
	operation_desc	varchar(25),
	--system columns
	start_lsn		binary(10) not null,
	end_lsn			binary(10) null,
	seqval			binary(10) not null,
	operation		int not null,
	update_mask		varbinary(128) null,
	--user table columns
	[DataProcessID] [int] NOT NULL,
	[DataProcessName] [nvarchar](75) NOT NULL,
	[MasterProcessID] [int] NOT NULL,
	[DataProcessTypeID] [int] NOT NULL,
	[Precedence] [int] NOT NULL,
	[Priority] [int] NOT NULL,
	[BatchSize] [int] NOT NULL,
	[Timeout] [int] NOT NULL,
	[SourceObject] [nvarchar](50) NULL,
	[DestObject] [nvarchar](50) NULL,
	[MetaDataMappingName] [nvarchar](50) NULL,
	[SourceConnectionID] [int] NULL,
	[DestConnectionID] [int] NULL,
	[MetaDataConnectionID] [int] NULL,
	[ProcessScript] [text] NULL,
	[ConditionalQuery] [text] NULL,
	[FormatFileContents] [text] NULL,
	[AbortMasterProcessOnError] [bit] NOT NULL,
	[BypassOnPriorError] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[LastUpdateDateTime] [datetime] NOT NULL,
	[MigrationFlag] [nvarchar](1) NULL,
	[MigrationIssue] [int] NULL,
	[Comment] [text] NULL,
	[CheckConstraint] [bit] NULL,	
	--lsn time mapping
	tran_begin_time datetime,
	tran_end_time	datetime
	)
	--drop table dbo.DT_DataProcess_CDC_history


	
	CREATE TABLE [dbo].[DT_MasterProcess_CDC_history](
		[operation_desc] [varchar](25) NULL,
		[start_lsn] [binary](10) NOT NULL,
		[end_lsn] [binary](10) NULL,
		[seqval] [binary](10) NOT NULL,
		[operation] [int] NOT NULL,
		[update_mask] [varbinary](128) NULL,
		[MasterProcessID] [int] NOT NULL,
		[MasterProcessName] [nvarchar](75) NOT NULL,
		[MasterProcessShortName] [nvarchar](20) NULL,
		[ExportFileFolder] [nvarchar](255) NULL,
		[ImportFileFolder] [nvarchar](255) NULL,
		[SupportEmailFrom] [nvarchar](255) NULL,
		[SupportEmailTo] [int] NULL,
		[SendReportOnCompletion] [bit] NOT NULL,
		[CreateDateTime] [datetime] NOT NULL,
		[IsDeleted] [bit] NOT NULL,
		[MigrationFlag] [nvarchar](1) NULL,
		[MigrationIssue] [int] NULL,
		[FailureEmailTo] [int] NULL,
		[Timeout] [int] NULL,
		[FailureTxtMsgTo] [int] NULL,
		[tran_begin_time] [datetime] NULL,
		[tran_end_time] [datetime] NULL
	) ON [SE2_TABLES]


