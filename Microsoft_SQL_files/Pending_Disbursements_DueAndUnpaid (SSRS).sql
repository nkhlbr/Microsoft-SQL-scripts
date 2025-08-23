SELECT Q1.* FROM (

/*

		Changes moved to production 12/04/2015:
			-did a "LEFT JOIN" on the AcctType domain table (instead of an INNER JOIN)
			-added VendorID to report (need to accomodate Custodians)
			-suppress those disbursements marked "Process Only"
			-suppress Pending transactions

		Changes moved to production 12/11/2015:
			-full support for Custodians
			-added column "Account Type"

		Changes moved to production 12/14/2015:
			-added Payee Address
			-added DisbursementID
			
		Changes moved to production 12/14/2015:
			-make payee address details sensitive to transaction process date
			-add address start/stop dates

		Changes moved to production 12/16/2015:
			-use Wir_WireState instead of Wir_State
			-change address start/stop dates conditional
			
*/

SELECT DISTINCT
	   --Q1.CycleDate											AS CycleDate 
	   Poh_POLICYNUMBER											AS PolicyNumber
	  ,CASE WHEN GrpPty.Pty_PARTYNUM IS NOT NULL 
			 THEN CAST('FT' + right('00000000' + CAST(GrpPty.Pty_PARTYNUM AS VARCHAR),8) AS CHAR(10)) 
			 ELSE CAST('FT' + right('00000000' + CAST(Pty.Pty_PARTYNUM AS VARCHAR),8) AS CHAR(10))
	   END														AS VendorID
	  ,Pst_DESCRIPTION_I										AS PolicyStatus
	  ,Eft_ID													AS DisbursementID
	  ,COALESCE(Wlt.Wlt_DESCRIPTION,'')							AS WatchListType
	  --,Com_Pro.Com_CODE											AS [ProcessingCompanyCode]
	  --,Com_Pro.Com_DESCRIPTION									AS [ProcessingCompanyName]
      --,com_iss.Com_CODE											AS [ProductCompanyCode]
      --,com_iss.Com_DESCRIPTION									AS [ProductCompanyName]
      --,Lob.Lob_DESCRIPTION										AS LineOfBusiness
      --,prm.Prm_CODE												AS [ProductModelCode]
      ,Prm.Prm_DESCRIPTION										AS ProdModelName
      ,Pmf.Pmf_DESCRIPTION										AS ProductName
	  ,LOB.Lob_DESCRIPTION										AS LineOfBusiness     
      ,pch.pch_PLANCODE											AS [PlanCode]
      ,pch.Pch_FORMNUM											AS [FormNum]
      ,pch.Pch_SEQUENCE											AS CovSeq						--	results isolated to only CovSeq 01 (below)
      --,csti.Pst_DESCRIPTION_I									AS CovergeStatus
      ,CONVERT(VARCHAR(10),Pch.Pch_ISSUEDATE,101)				AS CoverageIssueDate
	  ,txti.Txt_Description_I									AS TrxType
	  ,txs.Txs_Description_I									AS TrxStatus
      ,CONVERT(VARCHAR(10),Txh_EffectiveDate,101)				AS TrxEffectiveDate
	  , CASE WHEN COALESCE(CONVERT(VARCHAR(10),Txh_PROCESSEDDATE,101),'01/01/1900') = '01/01/1900' 
		     THEN ''		
		     ELSE CONVERT(VARCHAR(10),Txh_PROCESSEDDATE,101)
	    END  AS TrxProcessedDate
	  ,Ddt_DISBAMTALLOC											AS AmtRequested
	  ,Ddt_NETDISBAMT											AS AmtDisbursedNet
	  ,COALESCE(Stt.Stt_Name,'Not Entered')						AS DisbState
	  ,Dst.Dst_DESCRIPTION										AS DisbStatus
	  ,'EFT'													AS DisbType
	  ,COALESCE(Dtp.Dtp_DESCRIPTION,'')							AS DisbSubType
	  ,CONVERT(VARCHAR(10),Eft_TIMESTAMP,101)					AS Disb_DateStamp
	  ,COALESCE(Act.Act_DESCRIPTION_I,'Invalid Acct Type')		AS AccountType
      ,COALESCE(PCC.Pcc_DESCRIPTION,'')							AS ProcessingCode
      ,CASE WHEN Grp.Grp_ID IS NULL THEN 'No' ELSE 'Yes' END	AS GroupContract
	  --,_owner.Pty_FULLNAME										AS OwnerName
	  --,COALESCE(Grp.Grp_LEGALNAME,Pty.Pty_FULLNAME)				AS PayeeName

	  --,COALESCE(COALESCE(GrpAddr.Add_Line1,Addr.Add_Line1),'')	AS PayeeAddressLine1
	  --,COALESCE(COALESCE(GrpAddr.Add_Line2,Addr.Add_Line2),'')	AS PayeeAddressLine2
	  --,COALESCE(COALESCE(GrpAddr.Add_Line3,Addr.Add_Line3),'')	AS PayeeAddressLine3
	  --,COALESCE(COALESCE(GrpAddr.Add_Line4,Addr.Add_Line4),'')	AS PayeeAddressLine4
	  --,COALESCE(COALESCE(GrpAddr.Add_City,Addr.Add_City),'')	AS PayeeAddressCity
	  --,COALESCE(COALESCE(GrpStt.Stt_DESCRIPTION_I,Stti.Stt_DESCRIPTION_I),'')	AS PayeeAddressState
	  --,COALESCE(COALESCE(GrpAddr.Add_Zip,Addr.Add_Zip),'')		AS PayeeAddressZip
	  --,COALESCE(COALESCE(GrpNat.Nat_DESCRIPTION_I,Nat.Nat_DESCRIPTION_I),'')	AS PayeeAddressCountry

	  --,COALESCE(CONVERT(VARCHAR(10),JON_ADD.Pty_STARTDATE,101),'')	AS AddressStartDate
	  --,COALESCE(CONVERT(VARCHAR(10),JON_ADD.Pty_ENDDATE,101),'')	AS AddressEndDate
	  ----Cm_JON_GROUPBILLHDR_Pty_S should contain start/end dates for Group (but table is currently empty)	  

FROM Cm_Opt_Eft_EFT_S
		INNER JOIN Cm_Opt_Ddt_DisbDtl_S Ddt ON (Ddt.Ddt_ID = Cm_Opt_Eft_EFT_S.Eft_DISBDTLID)
		--LEFT OUTER JOIN Cm_Sys_Act_AccountType_S ON (Cm_Opt_Eft_EFT_S.Eft_ACCOUNTTYPE = Cm_Sys_Act_AccountType_S.Act_ID)
		INNER JOIN Cm_JON_TRXHDRDISBURSE_Dhd_S ON (Cm_JON_TRXHDRDISBURSE_Dhd_S.Tdb_DISBHDRID = Ddt.Ddt_DISBHDRID)
		INNER JOIN Cm_Opt_Dhd_DisbHdr_S Dhd ON (Cm_JON_TRXHDRDISBURSE_Dhd_S.Tdb_DISBHDRID = Dhd.Dhd_ID )
-----------------------------------------	Exclusions	10/19/2015	--	Start
		LEFT OUTER JOIN Cm_Sys_Dtp_DistribCode_S Dtp ON Dtp.Dtp_ID = Dhd_DISTRIBCODE
-----------------------------------------	Exclusions	10/19/2015	--	 End
		INNER JOIN Cm_Opt_Tdb_TrxHdrDisburse_S ON (Cm_Opt_Tdb_TrxHdrDisburse_S.Tdb_ID = Cm_JON_TRXHDRDISBURSE_Dhd_S.Tdb_TRXHDRDISBURSEID)
		left outer join Cm_Sys_Pcc_ProcessingCode_S PCC on Cm_Opt_Tdb_TrxHdrDisburse_S.tdb_processingcode = PCC.PCC_ID

		INNER JOIN Cm_Opt_Txh_TrxHdr_S ON (Cm_Opt_Txh_TrxHdr_S.Txh_ID = Cm_Opt_Tdb_TrxHdrDisburse_S.Tdb_TRXHDRID)
        left outer join Cm_Sys_Txs_TrxStatus_I txs on txh_trxStatus = txs_id_i
        left outer join Cm_Sys_Txt_TrxType_I txti on txh_trxtypeid = txti.txt_id_i
        
		INNER JOIN Cm_Opt_Poh_PolicyHdr_S Poh ON (Poh.Poh_ID = Cm_Opt_Txh_TrxHdr_S.Txh_POLICYHDRID)
		INNER JOIN Cm_Sys_Pst_PolicyStatus_I ON Pst_ID_I = Poh_Status
		INNER JOIN Cm_Sys_Lob_LineOfBiz_S LOB ON LOB.Lob_ID = Poh_LOB

		left outer join Cm_Cfg_Wlt_WatchListType_S Wlt ON Poh_WATCHLISTTYPE = Wlt.Wlt_ID
		inner join Cm_TEN_COMPANY_Poh_S poh_ten on(Poh.Poh_ID = poh_ten.Com_POLICYHDRID)
		inner join Cm_Cfg_Com_Company_S com_parent on(poh_ten.Com_COMPANYID = com_parent.Com_ID)
		inner join Cm_Opt_Pch_PolicyCovHdr_S pch on(Poh.Poh_ID = pch.Pch_POLICYHDRID and pch.Pch_ISBASECOVERAGE = 1)

		LEFT OUTER join Cm_Cfg_Pmf_ProdModelFormNum_S pmf on Poh_PRODMODELID = Pmf.Pmf_PRODMODELID AND pmf.Pmf_FORMNUM = pch.Pch_FORMNUM and pmf.Pmf_PLANCODE = pch.Pch_PLANCODE
		LEFT OUTER join Cm_Cfg_Prm_ProdModel_S prm on prm.Prm_ID = Poh_PRODMODELID

        LEFT OUTER JOIN 
			(
			  SELECT DISTINCT Poh_POLICYHDRID, Pty_FULLNAME, Roli.Rol_DESCRIPTION_I AS OwnerType
			  	FROM Cm_JON_POLICYHDR_Pty_Rol_S AS JON_ROLE 
					INNER JOIN Cm_Opt_Pty_Party_S AS ROLE ON ROLE.Pty_ID = JON_ROLE.Poh_PARTYID 
				  --FROM Cm_JON_POLICYCOVHDR_Pty_Rol_S	PTYRol
				  --INNER JOIN Cm_Opt_Pty_Party_S				Pty
						--ON PTYRol.Pch_PARTYID = Pty.Pty_ID
				  --INNER JOIN Cm_Opt_Psn_Person_S			Psn
						--ON Psn.Psn_PARTYID = Pty.Pty_ID  
				  LEFT OUTER JOIN Cm_Cfg_Rol_Role_I RolI ON RolI.Rol_ID_I = JON_ROLE.Poh_ROLEID
				  --LEFT OUTER JOIN Cm_JON_PARTY_Add_S JON_ADD ON  JON_ADD.Pty_PARTYID = Pty.Pty_ID
				  --LEFT OUTER JOIN Cm_Opt_Add_Address_S ADDR  ON  ADDR.Add_ID = JON_ADD.Pty_ADDRESSID
				  --LEFT OUTER JOIN Cm_Sys_Stt_State_I stti	 ON  stti.Stt_ID_I = ADDR.Add_ADDRESSSTATE
			  WHERE Roli.Rol_DESCRIPTION_I IN ('Owner','Co Owner')
			) AS _Owner ON _Owner.Poh_POLICYHDRID = Poh.Poh_ID

					LEFT OUTER JOIN Cm_JON_DISBDTL_Pty_S		JONDisb ON JONDisb.Ddt_DISBDTLID = Ddt.Ddt_ID
					LEFT OUTER JOIN Cm_Opt_Pty_Party_S			Pty     ON JONDisb.Ddt_PARTYID = Pty.Pty_ID
				    LEFT OUTER JOIN Cm_Opt_Psn_Person_S			Psn		ON Psn.Psn_PARTYID = Pty.Pty_ID  
					LEFT OUTER join Cm_JON_PARTY_Bfd_S			JONBfd	on (pTY.pty_id = JONBfd.Pty_PARTYID)
					LEFT OUTER join Cm_Opt_Bfd_BankDetails_S	Bfd		on (JONBfd.Pty_BANKDETAILSID = Bfd.bfd_id)
					LEFT OUTER Join Cm_Sys_Act_AccountType_I	Act		on Act.Act_ID_I = Bfd.Bfd_ACCOUNTTYPE
					
				-----------------------------------------------------

				  LEFT OUTER JOIN Cm_JON_PARTY_Add_S	JON_ADD	ON  JON_ADD.Pty_PARTYID = Pty.Pty_ID 
					AND CONVERT(date,Txh_PROCESSEDDATE) >= CONVERT(date,JON_ADD.Pty_STARTDATE) AND CONVERT(date,Txh_PROCESSEDDATE) < CONVERT(date,JON_ADD.Pty_ENDDATE)
				  LEFT OUTER JOIN Cm_Opt_Add_Address_S	ADDR	ON  ADDR.Add_ID = JON_ADD.Pty_ADDRESSID
				  left outer join Cm_Sys_Nat_Nation_I	NAT		on	ADDR.Add_Country = NAT.Nat_ID_I
				  LEFT OUTER JOIN Cm_Sys_Stt_State_I	STTI	ON  STTI.Stt_ID_I = ADDR.Add_ADDRESSSTATE

		left outer join cm_jon_grouphdr_poh_s		JONGrp		on (poh_id = JONGrp.Grp_POLICYHDRID)		
		Left Outer join cm_opt_grp_grouphdr_s		Grp			on (JONGrp.grp_grouphdrid = Grp.grp_id)
		LEFT OUTER JOIN cm_jon_grouphdr_pty_rol_s	GrpPtyRol	on Grp.grp_id = GrpPtyRol.grp_grouphdrid
---------
		LEFT OUTER JOIN Cm_Opt_Pty_Party_S			GrpPty		ON GrpPtyRol.grp_PARTYID = GrpPty.Pty_ID
		--inner join Cm_Cfg_Rol_Role_S				rol			on GrpPtyRol.Grp_ROLEID = rol.Rol_ID
		LEFT OUTER join Cm_JON_GROUPHDR_Add_Rol_S	GrpAddRol	on GrpPtyRol.Grp_GROUPHDRID = GrpAddRol.Grp_GROUPHDRID
		LEFT OUTER join Cm_Opt_Add_Address_S		GrpAddr		on GrpAddRol.Grp_ADDRESSID = GrpAddr.add_id and GrpAddr.Add_MAILINGADDRESSIND = 1
		left outer join Cm_Sys_Stt_State_I			GrpStt		on GrpAddr.Add_ADDRESSSTATE = GrpStt.Stt_ID_I
		left outer join Cm_Sys_Nat_Nation_I			GrpNat		on GrpAddr.Add_Country = GrpNat.Nat_ID_I
---------
		
		left outer join Cm_Sys_Dst_DisbStatus_S	Dst		on Dst.Dst_ID = eft_status 
		left outer join Cm_Sys_Stt_State_S		Stt		on (Cm_Opt_Eft_EFT_S.Eft_STATE = Stt.Stt_ID)

		
--WHERE  Cm_Opt_Eft_EFT_S.Eft_STATUS = '00000000-0000-0000-0000-000000000001'
--	   AND
WHERE  poh_ten.Com_COMPANYID = '00000000-0000-0000-0000-000000000010'							-- Delaware Life only
	   AND
	   Ddt_DISBAMTALLOC <> 0
	   AND
	   Txh_EFFECTIVEDATE > '10/03/2015'
	   AND
	   ISNULL(PCC.Pcc_DESCRIPTION,'') <> 'Process Only'
	   AND
	   txs.Txs_Description_I <> 'Pending'

--/*
	   
UNION							----------------------------------------------------------	CHECKS

SELECT DISTINCT
	   --Q1.CycleDate											AS CycleDate 
	   Poh_POLICYNUMBER											AS PolicyNumber
	  ,CASE WHEN GrpPty.Pty_PARTYNUM IS NOT NULL 
			 THEN CAST('FT' + right('00000000' + CAST(GrpPty.Pty_PARTYNUM AS VARCHAR),8) AS CHAR(10)) 
			 ELSE CAST('FT' + right('00000000' + CAST(Pty.Pty_PARTYNUM AS VARCHAR),8) AS CHAR(10))
	   END														AS VendorID
	  ,Pst_DESCRIPTION_I										AS PolicyStatus
	  ,Chk_ID													AS DisbursementID
	  ,COALESCE(Wlt.Wlt_DESCRIPTION,'')							AS WatchListType
	  --,Com_Pro.Com_CODE											AS [ProcessingCompanyCode]
	  --,Com_Pro.Com_DESCRIPTION									AS [ProcessingCompanyName]
   --   ,com_iss.Com_CODE											AS [ProductCompanyCode]
      --,com_iss.Com_DESCRIPTION									AS [ProductCompanyName]
      --,Lob.Lob_DESCRIPTION										AS LineOfBusiness
      --,prm.Prm_CODE												AS [ProductModelCode]
      ,Prm.Prm_DESCRIPTION										AS ProdModelName
      ,Pmf.Pmf_DESCRIPTION										AS ProductName
	  ,LOB.Lob_DESCRIPTION										AS LineOfBusiness 
      ,pch.pch_PLANCODE											AS [PlanCode]
      ,pch.Pch_FORMNUM											AS [FormNum]
      ,pch.Pch_SEQUENCE											AS CovSeq						--	results isolated to only CovSeq 01 (below)
      --,csti.Pst_DESCRIPTION_I									AS CovergeStatus
      ,CONVERT(VARCHAR(10),Pch.Pch_ISSUEDATE,101)				AS CoverageIssueDate
	  ,txti.Txt_Description_I									AS TrxType
	  ,txs.Txs_Description_I									AS TrxStatus
      ,CONVERT(VARCHAR(10),Txh_EffectiveDate,101)				AS TrxEffectiveDate
	  , CASE WHEN COALESCE(CONVERT(VARCHAR(10),Txh_PROCESSEDDATE,101),'01/01/1900') = '01/01/1900' 
		     THEN ''		
		     ELSE CONVERT(VARCHAR(10),Txh_PROCESSEDDATE,101)
	    END  AS TrxProcessedDate	  
	  ,Ddt_DISBAMTALLOC											AS AmtRequested
	  ,Ddt_NETDISBAMT											AS AmtDisbursedNet
	  ,COALESCE(Stt.Stt_Name,'Not Entered')						AS DisbState
	  ,Pst.Pst_DESCRIPTION										AS DisbStatus
	  ,'CHK'													AS DisbType
	  ,COALESCE(Dtp.Dtp_DESCRIPTION,'')							AS DisbSubType
	  ,CONVERT(VARCHAR(10),Chk_TIMESTAMP,101)					AS Disb_DateStamp
	  ,COALESCE(Act.Act_DESCRIPTION_I,'Invalid Acct Type')		AS AccountType
      ,COALESCE(PCC.Pcc_DESCRIPTION,'')							AS ProcessingCode
      ,CASE WHEN Grp.Grp_ID IS NULL THEN 'No' ELSE 'Yes' END	AS GroupContract
	  --,_owner.Pty_FULLNAME										AS OwnerName
	  --,COALESCE(Grp.Grp_LEGALNAME,Pty.Pty_FULLNAME)				AS PayeeName

	  --,COALESCE(COALESCE(GrpAddr.Add_Line1,Addr.Add_Line1),'')	AS PayeeAddressLine1
	  --,COALESCE(COALESCE(GrpAddr.Add_Line2,Addr.Add_Line2),'')	AS PayeeAddressLine2
	  --,COALESCE(COALESCE(GrpAddr.Add_Line3,Addr.Add_Line3),'')	AS PayeeAddressLine3
	  --,COALESCE(COALESCE(GrpAddr.Add_Line4,Addr.Add_Line4),'')	AS PayeeAddressLine4
	  --,COALESCE(COALESCE(GrpAddr.Add_City,Addr.Add_City),'')	AS PayeeAddressCity
	  --,COALESCE(COALESCE(GrpStt.Stt_DESCRIPTION_I,Stti.Stt_DESCRIPTION_I),'')	AS PayeeAddressState
	  --,COALESCE(COALESCE(GrpAddr.Add_Zip,Addr.Add_Zip),'')		AS PayeeAddressZip
	  --,COALESCE(COALESCE(GrpNat.Nat_DESCRIPTION_I,Nat.Nat_DESCRIPTION_I),'')	AS PayeeAddressCountry

	  --,COALESCE(CONVERT(VARCHAR(10),JON_ADD.Pty_STARTDATE,101),'')	AS AddressStartDate
	  --,COALESCE(CONVERT(VARCHAR(10),JON_ADD.Pty_ENDDATE,101),'')	AS AddressEndDate
	  ----Cm_JON_GROUPBILLHDR_Pty_S should contain start/end dates for Group (but table is currently empty)	
	  
	  	  
FROM Cm_Opt_Chk_Check_S
		INNER JOIN Cm_Opt_Ddt_DisbDtl_S Ddt ON (Ddt.Ddt_ID = Cm_Opt_Chk_Check_S.chk_DISBDTLID)
		--LEFT OUTER JOIN Cm_Sys_Act_AccountType_S ON (Cm_Opt_Chk_Check_S.chk_ACCOUNTTYPE = Cm_Sys_Act_AccountType_S.Act_ID)
		INNER JOIN Cm_JON_TRXHDRDISBURSE_Dhd_S ON (Cm_JON_TRXHDRDISBURSE_Dhd_S.Tdb_DISBHDRID = Ddt.Ddt_DISBHDRID)
		INNER JOIN Cm_Opt_Dhd_DisbHdr_S ON (Cm_JON_TRXHDRDISBURSE_Dhd_S.Tdb_DISBHDRID = Cm_Opt_Dhd_DisbHdr_S.Dhd_ID )
-----------------------------------------	Exclusions	10/19/2015	--	Start
		LEFT OUTER JOIN Cm_Sys_Dtp_DistribCode_S Dtp ON Dtp.Dtp_ID = Dhd_DISTRIBCODE
-----------------------------------------	Exclusions	10/19/2015	--	 End
		INNER JOIN Cm_Opt_Tdb_TrxHdrDisburse_S ON (Cm_Opt_Tdb_TrxHdrDisburse_S.Tdb_ID = Cm_JON_TRXHDRDISBURSE_Dhd_S.Tdb_TRXHDRDISBURSEID)
		left outer join Cm_Sys_Pcc_ProcessingCode_S PCC on Cm_Opt_Tdb_TrxHdrDisburse_S.tdb_processingcode = PCC.PCC_ID
		
		INNER JOIN Cm_Opt_Txh_TrxHdr_S ON (Cm_Opt_Txh_TrxHdr_S.Txh_ID = Cm_Opt_Tdb_TrxHdrDisburse_S.Tdb_TRXHDRID)
        left outer join Cm_Sys_Txs_TrxStatus_I txs on txh_trxStatus = txs_id_i
        left outer join Cm_Sys_Txt_TrxType_I txti on txh_trxtypeid = txti.txt_id_i 
		INNER JOIN Cm_Opt_Poh_PolicyHdr_S Poh ON (Poh.Poh_ID = Cm_Opt_Txh_TrxHdr_S.Txh_POLICYHDRID)
		INNER JOIN Cm_Sys_Pst_PolicyStatus_I ON Pst_ID_I = Poh_Status
		INNER JOIN Cm_Sys_Lob_LineOfBiz_S LOB ON LOB.Lob_ID = Poh_LOB

		left outer join Cm_Cfg_Wlt_WatchListType_S Wlt ON Poh_WATCHLISTTYPE = Wlt.Wlt_ID
		inner join Cm_TEN_COMPANY_Poh_S poh_ten on(Poh.Poh_ID = poh_ten.Com_POLICYHDRID)
		inner join Cm_Cfg_Com_Company_S com_parent on(poh_ten.Com_COMPANYID = com_parent.Com_ID)
		inner join Cm_Opt_Pch_PolicyCovHdr_S pch on(Poh.Poh_ID = pch.Pch_POLICYHDRID and pch.Pch_ISBASECOVERAGE = 1)

		LEFT OUTER join Cm_Cfg_Pmf_ProdModelFormNum_S pmf on Poh_PRODMODELID = Pmf.Pmf_PRODMODELID AND pmf.Pmf_FORMNUM = pch.Pch_FORMNUM and pmf.Pmf_PLANCODE = pch.Pch_PLANCODE
		LEFT OUTER join Cm_Cfg_Prm_ProdModel_S prm on prm.Prm_ID = Poh_PRODMODELID

        LEFT OUTER JOIN 
			(
			  SELECT DISTINCT Poh_POLICYHDRID, Pty_FULLNAME, Roli.Rol_DESCRIPTION_I AS OwnerType
			  	FROM Cm_JON_POLICYHDR_Pty_Rol_S AS JON_ROLE 
					INNER JOIN Cm_Opt_Pty_Party_S AS ROLE ON ROLE.Pty_ID = JON_ROLE.Poh_PARTYID 
				  --FROM Cm_JON_POLICYCOVHDR_Pty_Rol_S	PTYRol
				  --INNER JOIN Cm_Opt_Pty_Party_S				Pty
						--ON PTYRol.Pch_PARTYID = Pty.Pty_ID
				  --INNER JOIN Cm_Opt_Psn_Person_S			Psn
						--ON Psn.Psn_PARTYID = Pty.Pty_ID  
				  LEFT OUTER JOIN Cm_Cfg_Rol_Role_I RolI ON RolI.Rol_ID_I = JON_ROLE.Poh_ROLEID
				  --LEFT OUTER JOIN Cm_JON_PARTY_Add_S JON_ADD ON  JON_ADD.Pty_PARTYID = Pty.Pty_ID
				  --LEFT OUTER JOIN Cm_Opt_Add_Address_S ADDR  ON  ADDR.Add_ID = JON_ADD.Pty_ADDRESSID
				  --LEFT OUTER JOIN Cm_Sys_Stt_State_I stti	 ON  stti.Stt_ID_I = ADDR.Add_ADDRESSSTATE
			  WHERE Roli.Rol_DESCRIPTION_I IN ('Owner','Co Owner')
			) AS _Owner ON _Owner.Poh_POLICYHDRID = Poh.Poh_ID

					LEFT OUTER JOIN Cm_JON_DISBDTL_Pty_S		JONDisb ON JONDisb.Ddt_DISBDTLID = Ddt.Ddt_ID
					LEFT OUTER JOIN Cm_Opt_Pty_Party_S			Pty     ON JONDisb.Ddt_PARTYID = Pty.Pty_ID
				    LEFT OUTER JOIN Cm_Opt_Psn_Person_S			Psn		ON Psn.Psn_PARTYID = Pty.Pty_ID  
					LEFT OUTER join Cm_JON_PARTY_Bfd_S			JONBfd	on (pTY.pty_id = JONBfd.Pty_PARTYID)
					LEFT OUTER join Cm_Opt_Bfd_BankDetails_S	Bfd		on (JONBfd.Pty_BANKDETAILSID = Bfd.bfd_id)
					LEFT OUTER Join Cm_Sys_Act_AccountType_I	Act		on Act.Act_ID_I = Bfd.Bfd_ACCOUNTTYPE
					
				-----------------------------------------------------

				  LEFT OUTER JOIN Cm_JON_PARTY_Add_S	JON_ADD	ON  JON_ADD.Pty_PARTYID = Pty.Pty_ID 
					AND CONVERT(date,Txh_PROCESSEDDATE) >= CONVERT(date,JON_ADD.Pty_STARTDATE) AND CONVERT(date,Txh_PROCESSEDDATE) < CONVERT(date,JON_ADD.Pty_ENDDATE)
				  LEFT OUTER JOIN Cm_Opt_Add_Address_S	ADDR	ON  ADDR.Add_ID = JON_ADD.Pty_ADDRESSID
				  left outer join Cm_Sys_Nat_Nation_I	NAT		on	ADDR.Add_Country = NAT.Nat_ID_I
				  LEFT OUTER JOIN Cm_Sys_Stt_State_I	STTI	ON  STTI.Stt_ID_I = ADDR.Add_ADDRESSSTATE

		left outer join cm_jon_grouphdr_poh_s		JONGrp	on (poh_id = JONGrp.Grp_POLICYHDRID)		
		Left Outer join cm_opt_grp_grouphdr_s		Grp		on (JONGrp.grp_grouphdrid = Grp.grp_id)
		LEFT OUTER JOIN cm_jon_grouphdr_pty_rol_s	GrpPtyRol on Grp.grp_id = GrpPtyRol.grp_grouphdrid

---------
		LEFT OUTER JOIN Cm_Opt_Pty_Party_S			GrpPty		ON GrpPtyRol.grp_PARTYID = GrpPty.Pty_ID
		--inner join Cm_Cfg_Rol_Role_S				rol			on GrpPtyRol.Grp_ROLEID = rol.Rol_ID
		LEFT OUTER join Cm_JON_GROUPHDR_Add_Rol_S	GrpAddRol	on GrpPtyRol.Grp_GROUPHDRID = GrpAddRol.Grp_GROUPHDRID
		LEFT OUTER join Cm_Opt_Add_Address_S		GrpAddr		on GrpAddRol.Grp_ADDRESSID = GrpAddr.add_id and GrpAddr.Add_MAILINGADDRESSIND = 1
		left outer join Cm_Sys_Stt_State_I			GrpStt		on GrpAddr.Add_ADDRESSSTATE = GrpStt.Stt_ID_I
		left outer join Cm_Sys_Nat_Nation_I			GrpNat		on GrpAddr.Add_Country = GrpNat.Nat_ID_I
---------

		left outer join Cm_Sys_Pst_PaymentStatus_S	Pst		on Pst.Pst_ID = chk_status 
		left outer join Cm_Sys_Stt_State_S			Stt		on (Cm_Opt_Chk_Check_S.Chk_ADDRESSSTATE = Stt.Stt_ID)
		
--WHERE  Cm_Opt_Chk_Check_S.Chk_STATUS = '00000000-0000-0000-0000-000000000001'
--		AND
WHERE  poh_ten.Com_COMPANYID = '00000000-0000-0000-0000-000000000010'							-- Delaware Life only
	   AND
	   Ddt_DISBAMTALLOC <> 0
	   AND
	   Txh_EFFECTIVEDATE > '10/03/2015'
	   AND
	   ISNULL(PCC.Pcc_DESCRIPTION,'') <> 'Process Only'
	   AND
	   txs.Txs_Description_I <> 'Pending'
	   	   
UNION							----------------------------------------------------------	WIRES

SELECT DISTINCT
	   --Q1.CycleDate											AS CycleDate 
	   Poh_POLICYNUMBER											AS PolicyNumber
	  ,CASE WHEN GrpPty.Pty_PARTYNUM IS NOT NULL 
			 THEN CAST('FT' + right('00000000' + CAST(GrpPty.Pty_PARTYNUM AS VARCHAR),8) AS CHAR(10)) 
			 ELSE CAST('FT' + right('00000000' + CAST(Pty.Pty_PARTYNUM AS VARCHAR),8) AS CHAR(10))
	   END														AS VendorID
	  ,Pst_DESCRIPTION_I										AS PolicyStatus
	  ,Wir_ID													AS DisbursementID
	  ,COALESCE(Wlt.Wlt_DESCRIPTION,'')							AS WatchListType
	  --,Com_Pro.Com_CODE											AS [ProcessingCompanyCode]
	  --,Com_Pro.Com_DESCRIPTION									AS [ProcessingCompanyName]
   --   ,com_iss.Com_CODE											AS [ProductCompanyCode]
      --,com_iss.Com_DESCRIPTION									AS [ProductCompanyName]
      --,Lob.Lob_DESCRIPTION										AS LineOfBusiness
      --,prm.Prm_CODE												AS [ProductModelCode]
      ,Prm.Prm_DESCRIPTION										AS ProdModelName
      ,Pmf.Pmf_DESCRIPTION										AS ProductName
	  ,LOB.Lob_DESCRIPTION										AS LineOfBusiness 
      ,pch.pch_PLANCODE											AS [PlanCode]
      ,pch.Pch_FORMNUM											AS [FormNum]
      ,pch.Pch_SEQUENCE											AS CovSeq						--	results isolated to only CovSeq 01 (below)
      --,csti.Pst_DESCRIPTION_I									AS CovergeStatus
      ,CONVERT(VARCHAR(10),Pch.Pch_ISSUEDATE,101)				AS CoverageIssueDate
	  ,txti.Txt_Description_I									AS TrxType
	  ,txs.Txs_Description_I									AS TrxStatus
      ,CONVERT(VARCHAR(10),Txh_EffectiveDate,101)				AS TrxEffectiveDate
	  , CASE WHEN COALESCE(CONVERT(VARCHAR(10),Txh_PROCESSEDDATE,101),'01/01/1900') = '01/01/1900' 
		     THEN ''		
		     ELSE CONVERT(VARCHAR(10),Txh_PROCESSEDDATE,101)
	    END  AS TrxProcessedDate
	  ,Ddt_DISBAMTALLOC											AS AmtRequested
	  ,Ddt_NETDISBAMT											AS AmtDisbursedNet
	  ,COALESCE(Stt.Stt_Name,'Not Entered')						AS DisbState
	  ,Dst.Dst_DESCRIPTION										AS DisbStatus
	  ,'WIR'													AS DisbType
	  ,COALESCE(Dtp.Dtp_DESCRIPTION,'')							AS DisbSubType
	  ,CONVERT(VARCHAR(10),Wir_TIMESTAMP,101)					AS Disb_DateStamp
	  ,'Investment Account'										AS AccountType
      ,COALESCE(PCC.Pcc_DESCRIPTION,'')							AS ProcessingCode
      ,CASE WHEN Grp.Grp_ID IS NULL THEN 'No' ELSE 'Yes' END	AS GroupContract
	  --,_owner.Pty_FULLNAME										AS OwnerName
	  --,COALESCE(Grp.Grp_LEGALNAME,Pty.Pty_FULLNAME)				AS PayeeName

	  --,COALESCE(COALESCE(GrpAddr.Add_Line1,Addr.Add_Line1),'')	AS PayeeAddressLine1
	  --,COALESCE(COALESCE(GrpAddr.Add_Line2,Addr.Add_Line2),'')	AS PayeeAddressLine2
	  --,COALESCE(COALESCE(GrpAddr.Add_Line3,Addr.Add_Line3),'')	AS PayeeAddressLine3
	  --,COALESCE(COALESCE(GrpAddr.Add_Line4,Addr.Add_Line4),'')	AS PayeeAddressLine4
	  --,COALESCE(COALESCE(GrpAddr.Add_City,Addr.Add_City),'')	AS PayeeAddressCity
	  --,COALESCE(COALESCE(GrpStt.Stt_DESCRIPTION_I,Stti.Stt_DESCRIPTION_I),'')	AS PayeeAddressState
	  --,COALESCE(COALESCE(GrpAddr.Add_Zip,Addr.Add_Zip),'')		AS PayeeAddressZip
	  --,COALESCE(COALESCE(GrpNat.Nat_DESCRIPTION_I,Nat.Nat_DESCRIPTION_I),'')	AS PayeeAddressCountry


	  --,COALESCE(CONVERT(VARCHAR(10),JON_ADD.Pty_STARTDATE,101),'')	AS AddressStartDate
	  --,COALESCE(CONVERT(VARCHAR(10),JON_ADD.Pty_ENDDATE,101),'')	AS AddressEndDate
	  ----Cm_JON_GROUPBILLHDR_Pty_S should contain start/end dates for Group (but table is currently empty)	
	  
FROM Cm_Opt_Wir_WireTransfer_S
		INNER JOIN Cm_Opt_Ddt_DisbDtl_S Ddt ON (Ddt.Ddt_ID = Cm_Opt_Wir_WireTransfer_S.Wir_DISBDTLID)
		--LEFT OUTER JOIN Cm_Sys_Act_AccountType_S ON (Cm_Opt_Chk_Check_S.chk_ACCOUNTTYPE = Cm_Sys_Act_AccountType_S.Act_ID)
		INNER JOIN Cm_JON_TRXHDRDISBURSE_Dhd_S ON (Cm_JON_TRXHDRDISBURSE_Dhd_S.Tdb_DISBHDRID = Ddt.Ddt_DISBHDRID)
		INNER JOIN Cm_Opt_Dhd_DisbHdr_S ON (Cm_JON_TRXHDRDISBURSE_Dhd_S.Tdb_DISBHDRID = Cm_Opt_Dhd_DisbHdr_S.Dhd_ID )
-----------------------------------------	Exclusions	10/19/2015	--	Start
		LEFT OUTER JOIN Cm_Sys_Dtp_DistribCode_S Dtp ON Dtp.Dtp_ID = Dhd_DISTRIBCODE
-----------------------------------------	Exclusions	10/19/2015	--	 End
		INNER JOIN Cm_Opt_Tdb_TrxHdrDisburse_S ON (Cm_Opt_Tdb_TrxHdrDisburse_S.Tdb_ID = Cm_JON_TRXHDRDISBURSE_Dhd_S.Tdb_TRXHDRDISBURSEID)
		left outer join Cm_Sys_Pcc_ProcessingCode_S PCC on Cm_Opt_Tdb_TrxHdrDisburse_S.tdb_processingcode = PCC.PCC_ID
		
		INNER JOIN Cm_Opt_Txh_TrxHdr_S ON (Cm_Opt_Txh_TrxHdr_S.Txh_ID = Cm_Opt_Tdb_TrxHdrDisburse_S.Tdb_TRXHDRID)
        left outer join Cm_Sys_Txs_TrxStatus_I txs on txh_trxStatus = txs_id_i
        left outer join Cm_Sys_Txt_TrxType_I txti on txh_trxtypeid = txti.txt_id_i
        		
		INNER JOIN Cm_Opt_Poh_PolicyHdr_S Poh ON (Poh.Poh_ID = Cm_Opt_Txh_TrxHdr_S.Txh_POLICYHDRID)
		INNER JOIN Cm_Sys_Pst_PolicyStatus_I ON Pst_ID_I = Poh_Status
		INNER JOIN Cm_Sys_Lob_LineOfBiz_S LOB ON LOB.Lob_ID = Poh_LOB

		left outer join Cm_Cfg_Wlt_WatchListType_S Wlt ON Poh_WATCHLISTTYPE = Wlt.Wlt_ID
		inner join Cm_TEN_COMPANY_Poh_S poh_ten on(Poh.Poh_ID = poh_ten.Com_POLICYHDRID)
		inner join Cm_Cfg_Com_Company_S com_parent on(poh_ten.Com_COMPANYID = com_parent.Com_ID)
		inner join Cm_Opt_Pch_PolicyCovHdr_S pch on(Poh.Poh_ID = pch.Pch_POLICYHDRID and pch.Pch_ISBASECOVERAGE = 1)
					
		LEFT OUTER join Cm_Cfg_Pmf_ProdModelFormNum_S pmf on Poh_PRODMODELID = Pmf.Pmf_PRODMODELID AND pmf.Pmf_FORMNUM = pch.Pch_FORMNUM and pmf.Pmf_PLANCODE = pch.Pch_PLANCODE
		LEFT OUTER join Cm_Cfg_Prm_ProdModel_S prm on prm.Prm_ID = Poh_PRODMODELID
        
        LEFT OUTER JOIN 
			(
			  SELECT DISTINCT Poh_POLICYHDRID, Pty_FULLNAME, Roli.Rol_DESCRIPTION_I AS OwnerType
			  	FROM Cm_JON_POLICYHDR_Pty_Rol_S AS JON_ROLE 
					INNER JOIN Cm_Opt_Pty_Party_S AS ROLE ON ROLE.Pty_ID = JON_ROLE.Poh_PARTYID 
				  --FROM Cm_JON_POLICYCOVHDR_Pty_Rol_S	PTYRol
				  --INNER JOIN Cm_Opt_Pty_Party_S				Pty
						--ON PTYRol.Pch_PARTYID = Pty.Pty_ID
				  --INNER JOIN Cm_Opt_Psn_Person_S			Psn
						--ON Psn.Psn_PARTYID = Pty.Pty_ID  
				  LEFT OUTER JOIN Cm_Cfg_Rol_Role_I RolI ON RolI.Rol_ID_I = JON_ROLE.Poh_ROLEID
				  --LEFT OUTER JOIN Cm_JON_PARTY_Add_S JON_ADD ON  JON_ADD.Pty_PARTYID = Pty.Pty_ID
				  --LEFT OUTER JOIN Cm_Opt_Add_Address_S ADDR  ON  ADDR.Add_ID = JON_ADD.Pty_ADDRESSID
				  --LEFT OUTER JOIN Cm_Sys_Stt_State_I stti	 ON  stti.Stt_ID_I = ADDR.Add_ADDRESSSTATE
			  WHERE Roli.Rol_DESCRIPTION_I IN ('Owner','Co Owner')
			) AS _Owner ON _Owner.Poh_POLICYHDRID = Poh.Poh_ID

					LEFT OUTER JOIN Cm_JON_DISBDTL_Pty_S		JONDisb ON JONDisb.Ddt_DISBDTLID = Ddt.Ddt_ID
					LEFT OUTER JOIN Cm_Opt_Pty_Party_S			Pty     ON JONDisb.Ddt_PARTYID = Pty.Pty_ID
				    LEFT OUTER JOIN Cm_Opt_Psn_Person_S			Psn		ON Psn.Psn_PARTYID = Pty.Pty_ID  
					LEFT OUTER join Cm_JON_PARTY_Bfd_S			JONBfd	on (pTY.pty_id = JONBfd.Pty_PARTYID)
					LEFT OUTER join Cm_Opt_Bfd_BankDetails_S	Bfd		on (JONBfd.Pty_BANKDETAILSID = Bfd.bfd_id)
					LEFT OUTER Join Cm_Sys_Act_AccountType_I	Act		on Act.Act_ID_I = Bfd.Bfd_ACCOUNTTYPE

				-----------------------------------------------------

				  LEFT OUTER JOIN Cm_JON_PARTY_Add_S	JON_ADD	ON  JON_ADD.Pty_PARTYID = Pty.Pty_ID 
					AND CONVERT(date,Txh_PROCESSEDDATE) >= CONVERT(date,JON_ADD.Pty_STARTDATE) AND CONVERT(date,Txh_PROCESSEDDATE) < CONVERT(date,JON_ADD.Pty_ENDDATE)
				  LEFT OUTER JOIN Cm_Opt_Add_Address_S	ADDR	ON  ADDR.Add_ID = JON_ADD.Pty_ADDRESSID
				  left outer join Cm_Sys_Nat_Nation_I	NAT		on	ADDR.Add_Country = NAT.Nat_ID_I
				  LEFT OUTER JOIN Cm_Sys_Stt_State_I	STTI	ON  STTI.Stt_ID_I = ADDR.Add_ADDRESSSTATE

		left outer join cm_jon_grouphdr_poh_s			JONGrp	on (poh_id = JONGrp.Grp_POLICYHDRID)		
		Left Outer join cm_opt_grp_grouphdr_s			Grp		on (JONGrp.grp_grouphdrid = Grp.grp_id)
		LEFT OUTER JOIN cm_jon_grouphdr_pty_rol_s		GrpPtyRol on Grp.grp_id = GrpPtyRol.grp_grouphdrid

---------
		LEFT OUTER JOIN Cm_Opt_Pty_Party_S			GrpPty		ON GrpPtyRol.grp_PARTYID = GrpPty.Pty_ID
		--inner join Cm_Cfg_Rol_Role_S				rol			on GrpPtyRol.Grp_ROLEID = rol.Rol_ID
		LEFT OUTER join Cm_JON_GROUPHDR_Add_Rol_S	GrpAddRol	on GrpPtyRol.Grp_GROUPHDRID = GrpAddRol.Grp_GROUPHDRID
		LEFT OUTER join Cm_Opt_Add_Address_S		GrpAddr		on GrpAddRol.Grp_ADDRESSID = GrpAddr.add_id and GrpAddr.Add_MAILINGADDRESSIND = 1
		left outer join Cm_Sys_Stt_State_I			GrpStt		on GrpAddr.Add_ADDRESSSTATE = GrpStt.Stt_ID_I
		left outer join Cm_Sys_Nat_Nation_I			GrpNat		on GrpAddr.Add_Country = GrpNat.Nat_ID_I
---------

		left outer join Cm_Sys_Dst_DisbStatus_S	Dst		on Dst.Dst_ID = wir_status 
		left outer join Cm_Sys_Stt_State_S		Stt		on (Cm_Opt_Wir_WireTransfer_S.Wir_WireState = Stt.Stt_ID)
		
--WHERE  Cm_Opt_Wir_WireTransfer_S.wir_STATUS = '00000000-0000-0000-0000-000000000001'
--		AND
WHERE  poh_ten.Com_COMPANYID = '00000000-0000-0000-0000-000000000010'							-- Delaware Life only
	   AND
	   Ddt_DISBAMTALLOC <> 0
	   AND
	   Txh_EFFECTIVEDATE > '10/03/2015'
	   AND
	   ISNULL(PCC.Pcc_DESCRIPTION,'') <> 'Process Only'
	   AND
	   txs.Txs_Description_I <> 'Pending'

) AS Q1
--WHERE Q1.DisbState <> 'Not Entered'
--WHERE Q1.PayeeAddressLine1 = ''
--WHERE Q1.PolicyNumber = 'KA00980903-01A'
WHERE Q1.DisbStatus = 'Due and Unpaid'
ORDER BY Q1.DisbursementID