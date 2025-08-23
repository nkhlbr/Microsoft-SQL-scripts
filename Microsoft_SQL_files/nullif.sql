USE [se2FAST_TEST]
GO


 EXEC [se2FAST_TEST].dbo.sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"

delete from dbo.Cm_Cfg_Pmf_ProdModelFormNum_S

INSERT INTO [dbo].[Cm_Cfg_Pmf_ProdModelFormNum_S](Pmf_ID,[Pmf_PRODMODELID],[Pmf_FORMNUM],[Pmf_NAME],[Pmf_DESCRIPTION],[Pmf_ISSUINGCOMPANYID],[Pmf_GLPRODUCTCODE],[Pmf_SYSTEMCODE],[Pmf_PLANCODE],[Pmf_FORWARDPROCESSING],[Pmf_USERID],[Pmf_TIMESTAMP])
select                                           [Pmf_ID],[Pmf_PRODMODELID],[Pmf_FORMNUM],[Pmf_NAME],[Pmf_DESCRIPTION],[Pmf_ISSUINGCOMPANYID],[Pmf_GLPRODUCTCODE],[Pmf_SYSTEMCODE],[Pmf_PLANCODE],[Pmf_FORWARDPROCESSING],[Pmf_USERID],[Pmf_TIMESTAMP]
FROM [FAST_MASTER_CONFIG].dbo.Cm_Cfg_Pmf_ProdModelFormNum_S



delete from dbo.Cm_Opt_Gfg_GrpFormNumGLCodes_S

INSERT INTO [dbo].[Cm_Opt_Gfg_GrpFormNumGLCodes_S]([Gfg_ID],[Gfg_PMFID],[Gfg_INDIVIDUALGLCODE],[Gfg_GROUPGLCODE],[Gfg_NONLIFEGLCODE],[Gfg_LIFEGLCODE],[Gfg_USERID],[Gfg_TIMESTAMP])
SELECT [Gfg_ID],[Gfg_PMFID],[Gfg_INDIVIDUALGLCODE],[Gfg_GROUPGLCODE],[Gfg_NONLIFEGLCODE],[Gfg_LIFEGLCODE],[Gfg_USERID],[Gfg_TIMESTAMP] 
FROM [FAST_MASTER_CONFIG].[dbo].[Cm_Opt_Gfg_GrpFormNumGLCodes_S]

EXEC [se2FAST_TEST].dbo.sp_msforeachtable "ALTER TABLE ? CHECK CONSTRAINT all"

--select [Pmf_ID]
--      ,[Pmf_PRODMODELID]
--      ,[Pmf_FORMNUM]
--      ,[Pmf_NAME]
--      ,[Pmf_DESCRIPTION]
--      ,[Pmf_ISSUINGCOMPANYID]
--      ,[Pmf_GLPRODUCTCODE]
--	  ,nullif([Pmf_SYSTEMCODE],'NULL')
--      ,[Pmf_PLANCODE]
--      ,nullif([Pmf_FORWARDPROCESSING],'NULL')
--      ,NULLIF([Pmf_USERID],'null')
--      ,nullif([Pmf_TIMESTAMP],'null')
--  FROM [FAST_MASTER_CONFIG].[dbo].[TAMI]


--  select *
--  from [Cm_Cfg_Pmf_ProdModelFormNum_S]

--  select nullif(1+NULL, NULL)

  select *
  from dbo.Cm_Cfg_Pmf_ProdModelFormNum_S

SELECT * 
FROM dbo.Cm_Opt_Gfg_GrpFormNumGLCodes_S where Gfg_ID = '0EF33713-B8A5-4EDB-8357-01C4EF12C78D'
