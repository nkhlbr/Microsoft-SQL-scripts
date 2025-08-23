select 
	usr.Usr_LOGIN, 
	CASE WHEN CAST(mwa.Com_USERLOGINID as varchar(50)) is null then 0 ELSE 1 END as Modern,
	CASE WHEN CAST(dl.Com_USERLOGINID as varchar(50)) is null then 0 ELSE 1 END as Delaware,
	CASE WHEN CAST(rl.Com_USERLOGINID as varchar(50)) is null then 0 ELSE 1 END as Resolution
from 
	cc_opt_usr_userlogin_s  usr
	left outer join Cm_JON_COMPANY_Usr_Urt_S mwa on(usr.Usr_ID = mwa.Com_USERLOGINID and mwa.Com_COMPANYID = '00000000-0000-0000-0000-000000000009')
	left outer join Cm_JON_COMPANY_Usr_Urt_S dl on(usr.Usr_ID = dl.Com_USERLOGINID and dl.Com_COMPANYID = '00000000-0000-0000-0000-000000000010')
	left outer join Cm_JON_COMPANY_Usr_Urt_S rl on(usr.Usr_ID = rl.Com_USERLOGINID and rl.Com_COMPANYID = '00000000-0000-0000-0000-000000000014')








