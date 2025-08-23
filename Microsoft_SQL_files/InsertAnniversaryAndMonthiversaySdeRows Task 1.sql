--USE Se2FAST_DLOPS;

/* ACHTUNG !!!!!!  SET THESE VALUES BEFORE PROCEEDING */
DECLARE @cycleDate  DATETIME =	'2014-01-01' ; /* This is the next processing date that will be used on FAST. */
DECLARE @compGuid   UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000010';
/* Table and Cursor */
DECLARE @pol TABLE(POL VARCHAR(MAX));

INSERT INTO @pol VALUES('0004034125');
INSERT INTO @pol VALUES('0004036055');
INSERT INTO @pol VALUES('0004040605');
INSERT INTO @pol VALUES('0004077980');

DECLARE CONT INSENSITIVE SCROLL 
CURSOR 
FOR SELECT Poh_PolicyNumber
FROM dbo.Cm_Opt_Poh_PolicyHdr_S
INNER JOIN dbo.Cm_Ten_Company_Poh_S TCPH ON(TCPH.Com_PolicyHdrId = Poh_Id
			                            AND  TCPH.Com_CompanyId = @compGuid)
WHERE  Poh_PolicyNumber IN
						(     '0004034125'
							, '0004036055'
							, '0004040605'
							, '0004077980'  );

/* END SETUP -----------------------------------------*/
DECLARE @polNum     VARCHAR(MAX);
DECLARE @issDate    DATETIME;
DECLARE @matDate    DATETIME;
DECLARE @annSdeGuid UNIQUEIDENTIFIER;
DECLARE @mvaSdeGuid UNIQUEIDENTIFIER;
DECLARE @matSdeGuid UNIQUEIDENTIFIER;
DECLARE @pohGuid    UNIQUEIDENTIFIER;
DECLARE @mvaNxtDate DATETIME;
DECLARE @annNxtDate DATETIME;
DECLARE @company    VARCHAR(MAX);
DECLARE @diff       INT;

OPEN CONT

PRINT ' POL_NUM  |              POH_GUID              |         ANN_SDE_GUID               |         MVA_SDE_GUID               |  ISS_DT  |  ANN_DT  |  MVA_DT' 

-- Perform the first fetch.
FETCH NEXT FROM CONT INTO @polNum;

-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @annSdeGuid = ( SELECT NEWID() );
	SET @mvaSdeGuid = ( SELECT NEWID() );

	SET @pohGuid = (  SELECT Poh_Id 
					  FROM dbo.Cm_Opt_Poh_PolicyHdr_S 
					  INNER JOIN dbo.Cm_Ten_Company_Poh_S TCPH ON(TCPH.Com_PolicyHdrId = Poh_Id
															  AND  TCPH.Com_CompanyId = @compGuid)
					   WHERE Poh_PolicyNumber = @polNum );

	SET @issDate = (  SELECT PCH.Pch_IssueDate
					  FROM dbo.Cm_Opt_Pch_PolicyCovHdr_S PCH
					  INNER JOIN dbo.Cm_Opt_Poh_PolicyHdr_S POH ON(POH.Poh_id = PCH.Pch_PolicyHdrId)
					  INNER JOIN dbo.Cm_Ten_Company_Poh_S TCPH ON(TCPH.Com_PolicyHdrId = POH.Poh_Id
															  AND  TCPH.Com_CompanyId = @compGuid)
					  WHERE POH.Poh_PolicyNumber = @polNum AND PCH.Pch_Sequence = 1
				   );

	SET @company = ( SELECT Com_DESCRIPTION FROM dbo.Cm_Cfg_Com_Company_S WHERE Com_ID = @compGuid );

	/* Calculate Next Anniversary Date */
	SET @diff       = (SELECT DATEDIFF(year, @issDate, @cycleDate));
	SET @annNxtDate = (SELECT DATEADD(year,  @diff,    @issDate));
	SET @annNxtDate = (SELECT CASE WHEN  @annNxtDate < @cycleDate THEN DATEADD(year, 1, @annNxtDate)   ELSE @annNxtDate END);
	/* Calculate Next Monthiversary Date */
	SET @diff       = (SELECT DATEDIFF(month, @issDate, @cycleDate));
	SET @mvaNxtDate = (SELECT DATEADD(month,  @diff,    @issDate));
	SET @mvaNxtDate = (SELECT CASE WHEN  @mvaNxtDate < @cycleDate  THEN DATEADD(month, @diff + 1, @issDate)    ELSE @mvaNxtDate END);
	SET @mvaNxtDate = (SELECT CASE WHEN  @mvaNxtDate = @annNxtDate THEN DATEADD(month, 1,         @annNxtDate) ELSE @mvaNxtDate END);

	PRINT CAST(@polNum AS VARCHAR(50)) + '|' + CAST(@pohGuid AS VARCHAR(50)) + '|'  + CAST(@annSdeGuid AS VARCHAR(50)) + '|'   + CAST(@mvaSdeGuid AS VARCHAR(50)) + '|' + CONVERT(VARCHAR(10), @issDate, 120) + '|' + CONVERT(VARCHAR(10), @annNxtDate, 120) + '|' + CONVERT(VARCHAR(10), @mvaNxtDate, 120) 
	/* BEGIN MVA Insert */
	INSERT INTO [dbo].[Cm_Opt_Sde_SchEvt_S]
           ([Sde_ID]
           ,[Sde_EVTTYPE]
           ,[Sde_STARTDATE]
           ,[Sde_ENDDATE]
           ,[Sde_TERMINATIONDATE]
           ,[Sde_MODE]
           ,[Sde_NEXTDATE]
           ,[Sde_STATUS]
           ,[Sde_REFERENCEDATE]
           ,[Sde_DAYOFMONTH]
           ,[Sde_LEADTIME]
           ,[Sde_LASTDAYOFMONTH]
           ,[Sde_SEMIMONTHLY1STDAY]
           ,[Sde_SEMIMONTHLY2NDDAY]
           ,[Sde_EVERY]
           ,[Sde_STOPMONTH]
           ,[Sde_BUSINESSDAYONLY]
           ,[Sde_ISPREVDAYPROCESS]
           ,[Sde_USERID]
           ,[Sde_TIMESTAMP])
     VALUES
           (@mvaSdeGuid
           ,'00000000-0000-0000-0000-000000000010'
           ,@issDate
           ,'2999-12-31'
           ,'2999-12-31'
           ,'00000000-0000-0000-0000-000000000006'
           ,@mvaNxtDate
           ,'00000000-0000-0000-0000-000000000002'
           ,'2013-12-31'
           ,0
           ,1
           ,CASE WHEN DATEPART(DAY, @issDate) = DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,@issDate),0))) THEN 1 ELSE 0 END
           ,0
           ,0
           ,0
           ,NULL
           ,0
           ,1
           ,'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
           ,CURRENT_TIMESTAMP)

	INSERT INTO [dbo].[Cm_TEN_COMPANY_Sde_S]
           ([Com_COMPANYID]
           ,[Com_SCHEVTID]
           ,[Com_USERID]
           ,[Com_TIMESTAMP])
     VALUES
           (@compGuid
           ,@mvaSdeGuid
           ,'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
           ,CURRENT_TIMESTAMP)

	INSERT INTO [dbo].[Cm_JON_POLICYHDR_Sde_S]
           ([Poh_POLICYHDRID]
           ,[Poh_SCHEVTID]
           ,[Poh_USERID]
           ,[Poh_TIMESTAMP])
     VALUES
           (@pohGuid
           ,@mvaSdeGuid
           ,'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
           ,CURRENT_TIMESTAMP)
	/* BEGIN ANN Insert */
																																										INSERT INTO [dbo].[Cm_Opt_Sde_SchEvt_S]
           ([Sde_ID]
           ,[Sde_EVTTYPE]
           ,[Sde_STARTDATE]
           ,[Sde_ENDDATE]
           ,[Sde_TERMINATIONDATE]
           ,[Sde_MODE]
           ,[Sde_NEXTDATE]
           ,[Sde_STATUS]
           ,[Sde_REFERENCEDATE]
           ,[Sde_DAYOFMONTH]
           ,[Sde_LEADTIME]
           ,[Sde_LASTDAYOFMONTH]
           ,[Sde_SEMIMONTHLY1STDAY]
           ,[Sde_SEMIMONTHLY2NDDAY]
           ,[Sde_EVERY]
           ,[Sde_STOPMONTH]
           ,[Sde_BUSINESSDAYONLY]
           ,[Sde_ISPREVDAYPROCESS]
           ,[Sde_USERID]
           ,[Sde_TIMESTAMP])
     VALUES
           (@annSdeGuid
           ,'00000000-0000-0000-0000-000000000042'
           ,@issDate
           ,'2999-12-31'
           ,'2999-12-31'
           ,'00000000-0000-0000-0000-000000000011'
           ,@annNxtDate
           ,'00000000-0000-0000-0000-000000000002'
           ,'2013-12-31'
           ,0
           ,0
           ,CASE WHEN DATEPART(DAY, @issDate) = DAY(DATEADD(DAY,-1,DATEADD(MONTH,DATEDIFF(MONTH, -1, @issDate),0))) THEN 1 ELSE 0 END
           ,0
           ,0
           ,0
           ,NULL
           ,0
           ,0
           ,'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
           ,CURRENT_TIMESTAMP)
	INSERT INTO [dbo].[Cm_TEN_COMPANY_Sde_S]
           ([Com_COMPANYID]
           ,[Com_SCHEVTID]
           ,[Com_USERID]
           ,[Com_TIMESTAMP])
     VALUES
           (@compGuid
           ,@annSdeGuid
           ,'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
           ,CURRENT_TIMESTAMP)

	INSERT INTO [dbo].[Cm_JON_POLICYHDR_Sde_S]
           ([Poh_POLICYHDRID]
           ,[Poh_SCHEVTID]
           ,[Poh_USERID]
           ,[Poh_TIMESTAMP])
     VALUES
           (@pohGuid
           ,@annSdeGuid
           ,'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
           ,CURRENT_TIMESTAMP)
/* END ANN Insert */

/* BEGIN MAT Insert */
IF NOT EXISTS
	(
		SELECT  SDE.Sde_Id FROM dbo.Cm_Opt_Sde_SchEvt_S SDE

		INNER JOIN dbo.Cm_Jon_PolicyHdr_Sde_S JPSD ON(JPSD.Poh_SCHEVTID = SDE.Sde_Id)
		INNER JOIN dbo.Cm_Opt_Poh_PolicyHdr_S POH  ON(POH.Poh_Id = JPSD.Poh_PolicyHdrId)
		INNER JOIN dbo.Cm_Ten_Company_Sde_S   TCS  ON(TCS.Com_SCHEVTID = JPSD.Poh_SCHEVTID AND TCS.Com_CompanyId =  @compGuid)
		INNER JOIN dbo.Cm_Cfg_Ety_EvtType_S   ETY  ON(ETY.Ety_Id = SDE.Sde_EvtType)

		WHERE POH.Poh_PolicyNumber = @polNum AND ETY.Ety_DESCRIPTION = 'Maturity'
	)
BEGIN

	INSERT INTO [dbo].[Cm_Opt_Sde_SchEvt_S]
           ([Sde_ID]
           ,[Sde_EVTTYPE]
           ,[Sde_STARTDATE]
           ,[Sde_ENDDATE]
           ,[Sde_TERMINATIONDATE]
           ,[Sde_MODE]
           ,[Sde_NEXTDATE]
           ,[Sde_STATUS]
           ,[Sde_REFERENCEDATE]
           ,[Sde_DAYOFMONTH]
           ,[Sde_LEADTIME]
           ,[Sde_LASTDAYOFMONTH]
           ,[Sde_SEMIMONTHLY1STDAY]
           ,[Sde_SEMIMONTHLY2NDDAY]
           ,[Sde_EVERY]
           ,[Sde_STOPMONTH]
           ,[Sde_BUSINESSDAYONLY]
           ,[Sde_ISPREVDAYPROCESS]
           ,[Sde_USERID]
           ,[Sde_TIMESTAMP]
		   ,[Sde_REBALANCETYPE])
     VALUES
           (@matSdeGuid
           ,'00000000-0000-0000-0000-000000000011'
           ,@issDate
           ,'2999-12-31'
           ,'2999-12-31'
           ,'00000000-0000-0000-0000-000000000012'
           ,@matDate
           ,'00000000-0000-0000-0000-000000000002'
           ,'2013-12-31'
           ,NULL
           ,0
           ,0
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,0
           ,0
           ,'FFFFFFFF-0000-0000-0000-000000000000'
           ,CURRENT_TIMESTAMP
		   ,NULL)

	INSERT INTO [dbo].[Cm_TEN_COMPANY_Sde_S]
           ([Com_COMPANYID]
           ,[Com_SCHEVTID]
           ,[Com_USERID]
           ,[Com_TIMESTAMP])
     VALUES
           (@compGuid
           ,@matSdeGuid
           ,'FFFFFFFF-0000-0000-0000-000000000000'
           ,CURRENT_TIMESTAMP)

	INSERT INTO [dbo].[Cm_JON_POLICYHDR_Sde_S]
           ([Poh_POLICYHDRID]
           ,[Poh_SCHEVTID]
           ,[Poh_USERID]
           ,[Poh_TIMESTAMP])
     VALUES
           (@pohGuid 
           ,@matSdeGuid
           ,'FFFFFFFF-0000-0000-0000-000000000000'
           ,CURRENT_TIMESTAMP)

END;

   FETCH NEXT FROM CONT INTO @polNum;
END

/* BEGIN Query Results */
SELECT POH.Poh_PolicyNumber, ETY.Ety_DESCRIPTION AS EVT_TYP, SDE.* FROM dbo.Cm_Opt_Sde_SchEvt_S SDE

INNER JOIN dbo.Cm_Jon_PolicyHdr_Sde_S JPSD ON(JPSD.Poh_SCHEVTID = SDE.Sde_Id)
INNER JOIN dbo.Cm_Opt_Poh_PolicyHdr_S POH  ON(POH.Poh_Id = JPSD.Poh_PolicyHdrId)
INNER JOIN @pol                       P    ON(P.POL = POH.Poh_PolicyNumber)
INNER JOIN dbo.Cm_Ten_Company_Sde_S   TCS  ON(TCS.Com_SCHEVTID = JPSD.Poh_SCHEVTID AND TCS.Com_CompanyId =  @compGuid)
INNER JOIN dbo.Cm_Cfg_Ety_EvtType_S   ETY  ON(ETY.Ety_Id = SDE.Sde_EvtType)

ORDER BY POH.Poh_PolicyNumber, ETY.Ety_DESCRIPTION

/* END Query Results */

CLOSE CONT;
DEALLOCATE CONT;

