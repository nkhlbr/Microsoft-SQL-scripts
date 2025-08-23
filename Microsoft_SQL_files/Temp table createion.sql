









IF NOT EXISTS (SELECT *
	           FROM [dbo].[CommutationInputDL] 
	           WHERE SurrenderValue IS NULL 
	           )
BEGIN
	TRUNCATE TABLE [dbo].[CommutationInputDL]
END









if OBJECT_ID('POLICY_STATUS_TMP', 'U') IS NOT NULL DROP TABLE POLICY_STATUS_TMP;

select 
    Poh_ID, Poh_POLICYNUMBER, Poh_STATUS 
into
    POLICY_STATUS_TMP
from 
    Cm_Opt_Poh_PolicyHdr_S
	join 
        Cm_TEN_COMPANY_Poh_S 
		on  Cm_TEN_COMPANY_Poh_S.Com_POLICYHDRID = Poh_ID
        AND Cm_TEN_COMPANY_Poh_S.Com_COMPANYID = '00000000-0000-0000-0000-000000000010' -- Delaware Life
;


select * from dbo.POLICY_STATUS_TMP
BEGIN TRAN;

UPDATE
    cm_opt_poh_policyhdr_s
Set
    Poh_STATUS = '00000000-0000-0000-0000-000000000034' -- SUSPEND (ACTIVE)
from
    cm_opt_poh_policyhdr_s
	join 
        Cm_TEN_COMPANY_Poh_S 
		on  Cm_TEN_COMPANY_Poh_S.Com_POLICYHDRID = Poh_ID
        AND Cm_TEN_COMPANY_Poh_S.Com_COMPANYID = '00000000-0000-0000-0000-000000000010' -- Delaware Life
where
    Poh_PolicyNumber 
    Not IN
    (
     'UL0002754'
    ,'UL0004025'
    ,'UL0005204'
    ,'UL0005291'
    ,'UL0009627'
    ,'UL0009654'
    ,'UL0010456'
    ,'UL0012897'
    ,'UL0013373'
    ,'UL0013619'
    ,'UL0014005'
    ,'UL0014275'
    ,'UL0014321'
    ,'UL0014854'
    ,'UL0015733'
    ,'UL0017014'
    ,'UL0019547'
    ,'UL0019548'
    ,'UL0019549'
    ,'UL0019917'
    ,'UL0019919'
    ,'UL0020421'
    ,'UL0020716'
    ,'UL0020717'
    ,'UL0020724'
    ,'UL0021057'
    ,'UL0021058'
    ,'UL0021059'
    ,'UL0022066'
    ,'UL0022067'
    ,'UL0022068'
    ,'UL0022532'
    ,'UL0022533'
    ,'UL0022887'
    ,'UL0022952'
    ,'UL0022981'
    ,'UL0023413'
    ,'UL0023915'
    ,'UL0024115'
    ,'UL0024117'
    ,'UL0024119'
    ,'UL0024146'
    ,'UL0024147'
    ,'UL0024148'
    ,'UL0024485'
    ,'UL0024486'
    ,'UL0024526'
    ,'UL0024929'
    ,'UL0025433'
    ,'UL0025701'
    ,'UL0025709'
    ,'UL0025789'
    ,'UL0026247'
    ,'UL0026890'
    ,'UL0027126'
    ,'UL0027163'
    ,'UL0027330'
    ,'UL0028568'
    ,'UL0028569'
    ,'UL0028570'
    ,'UL0028571'
    ,'UL0028601'
    ,'UL0028664'
    ,'UL0028841'
    ,'UL0029256'
    ,'UL0029257'
    ,'UL0030012'
    ,'UL0030611'
    ,'UL0030742'
    ,'UL0030743'
    ,'UL0030991'
    ,'UL0030992'
    ,'UL0031324'
    ,'UL0032247'
    ,'UL0032270'
    ,'UL0032616'
    ,'UL0033160'
    ,'UL0034733'
    ,'UL0034849'
    ,'UL0035930'
    ,'UL0036471'
    ,'UL0036589'
    ,'UL0037384'
    ,'UL0038344'
    ,'UL0038345'
    ,'UL0038565'
    ,'UL0038859'
    ,'UL0038933'
    ,'UL0039011'
    ,'UL0039346'
    ,'UL0039490'
    ,'UL0039550'
    ,'UL0039613'
    ,'UL0039956'
    ,'UL0040033'
    ,'UL0040138'
    ,'UL0040272'
    ,'UL0040299'
    ,'UL0040678'
    ,'UL0040803'
    ,'UL0040884'
    ,'UL0041315'
    ,'UL0041750'
    ,'UL0041966'
    ,'UL0042106'
    ,'UL0042107'
    ,'UL0042278'
    ,'UL0042840'
    ,'UL0043036'
    ,'UL0043052'
    ,'UL0043060'
    ,'UL0043101'
    ,'UL0043298'
    ,'UL0043443'
    ,'UL0044163'
    )
;

--ROLLBACK;
--COMMIT;

