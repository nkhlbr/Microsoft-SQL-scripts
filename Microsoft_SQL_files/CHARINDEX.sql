DECLARE @var_name VARCHAR(100) = 'HOGENTOGLER, ZACHARY GRANT';

SELECT @var_name AS Before
     
, CHARINDEX (',', @var_name) AS Pos

, SUBSTRING(@var_name, CHARINDEX (',', @var_name) + 1, LEN(@var_name) - (CHARINDEX (',', @var_name, 1))) AS FirstName

, SUBSTRING(@var_name, CHARINDEX (',', @var_name) + 1, LEN(@var_name) - (CHARINDEX (',', @var_name, 1))) 
        
+ ' ' + 
SUBSTRING(@var_name, 1, CHARINDEX (',', @var_name)-1) AS EntireName


-- DECLARE @var_name VARCHAR(100);

-- SET     @var_name = 'HOGENTOGLER, ZACHARY GRANT';

-- SELECT 

-- SUBSTRING(@var_name, CHARINDEX (',', @var_name, 1) + 1, LEN(@var_name) - (CHARINDEX (',', @var_name, 1))) 
        
-- + ' ' + SUBSTRING(@var_name, 1, CHARINDEX (',', @var_name, 1) - 1) AS Name

-- - towards left
-- + towards right

select substring(@var_name, charindex (',', @var_name) + 1), substring(@var_name,1, CHARINDEX(',', @var_name)-1) AS EntireName


 SELECT MAX(sde.Sde_TIMESTAMP) LastCycleDate
from Cm_TEN_COMPANY_Sde_S                 TENSde 
      inner join Cm_Opt_Sde_SchEvt_S      Sde         on TENSde.Com_SCHEVTID = Sde.Sde_ID
where 
Com_COMPANYID = '00000000-0000-0000-0000-000000000010'            -- Delaware Life ONLY
AND
Sde_EVTTYPE in (SELECT Ety_ID FROM Cm_Cfg_Ety_EvtType_S WHERE Ety_Code = 'TrxProcessing')
AND
Sde_USERID = 'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'




SELECT right( 'HOGENTOGLER, ZACHARY GRANT', len ('HOGENTOGLER, ZACHARY GRANT') -CHARINDEX(',', 'HOGENTOGLER, ZACHARY GRANT')) 

+ ',' + left ('HOGENTOGLER, ZACHARY GRANT',CHARINDEX(',', 'HOGENTOGLER, ZACHARY GRANT')- 1); 

