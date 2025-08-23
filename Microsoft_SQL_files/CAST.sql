




CAST('FT' + RIGHT('00000000' + CAST(pty.pty_partynum AS VARCHAR), 8) AS CHAR))


SELECT RowId, ('YB' + REPLICATE('0', 8- LEN(ROWID)) + CAST(RowId AS VARCHAR)) 
FROM dbo._MasterConfigVersion




SELECT Pty_FAX, CAST('YB' + RIGHT('0000000' + CAST(Pty_PARTYNUM AS VARCHAR),7) AS CHAR(9)) FROM Cm_Opt_Pty_Party_S
SELECT RowId, ('YB' + REPLICATE('0', 8- LEN(ROWID)) + CAST(RowId AS VARCHAR)) 
FROM dbo._MasterConfigVersion 





SELECT INX.*
,sum (NUMVAL)
, CASE NMBR 
                                WHEN 0 THEN NMBR + 2 
                                ELSE NMBR + 3 
                          END AS NUMVAL 
FROM ( 
        (SELECT 1 AS NMBR UNION ALL SELECT 0  AS NMBR UNION ALL  SELECT 0  AS NMBR UNION ALL SELECT 1  AS NMBR UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 0 UNION ALL SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 0 UNION ALL SELECT 1) 

) AS INX 
group by NUMVAL

SELECT INX.*
, CASE NMBR 
                                WHEN 0 THEN NMBR + 2 
                                ELSE NMBR + 3 
                          END AS NUMVAL 
FROM ( 
        (SELECT 1 AS NMBR 
		UNION ALL SELECT 0   
		UNION ALL SELECT 0  
		UNION ALL SELECT 1  
		UNION ALL SELECT 1 
		UNION ALL SELECT 1 
		UNION ALL SELECT 1 
		UNION ALL SELECT 0 
		UNION ALL SELECT 0 
		UNION ALL SELECT 1 
		UNION ALL SELECT 0 
		UNION ALL SELECT 1 
		UNION ALL SELECT 0 
		UNION ALL SELECT 1 
		UNION ALL SELECT 0 
		UNION ALL SELECT 1) 

) AS INX 


SELECT Pty_FAX, Pty_PARTYNUM FROM Cm_Opt_Pty_Party_S

Id  Name  Sex  Salary
1   A     m    2500
2   B     f    1500
3   C     m    5500
4   D     f    500 

Update Salaries set salary  = 2500 where 



WITH CTE as (select user_training_id, user_id, training_id, training_date, RN =  row_number() 
inner join users u on u.user_id = td.user_id  over (partition by training_date) from  training_details td)
SELECT * FROM CTE WHERE CTE.RN > 1 group by username, 

select username, user_id,  training_date, count (*) from training_details td
inner join users u on u.user_id = td.user_id
group by username, user_id,  training_date
having count (*) > 1
order by training_date DESC


CAST(CAST(CASE Pch_TERMINATIONDATE WHEN '1900-01-01' THEN NULL 
	    ELSE Pch_TERMINATIONDATE 
	   END AS DATE) AS VARCHAR(10))  AS TERM_DT




	           CASE WHEN PIA.Pia_FINALCERTPMTDATE IS NOT NULL THEN
                                                CAST(MDD.Mod_PAYMENTSPERYEAR * DATEDIFF(MONTH, sde.Sde_NEXTDATE, PIA.Pia_FINALCERTPMTDATE) / 12.0 AS INTEGER) + 1
                                                ELSE NULL