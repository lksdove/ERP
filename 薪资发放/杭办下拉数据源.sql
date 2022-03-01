SELECT
	xs_jc_bank_internet_info.bank_id,
	xs_jc_bank_internet_info.account_no,
	xs_jc_bank_internet_info.bank_short_name,
	xs_jc_bank_internet_info.internet_flag,
	xs_jc_bank_internet_info.bank_short_no,
	xs_jc_bank_internet_info.account_short_name 
FROM
	xs_jc_bank_internet_info 
WHERE
	xs_jc_bank_internet_info.the_status IN ( '有效', '冻结' ) 
	AND  xs_jc_bank_internet_info.account_type IN ( '本地', '异地' )
	AND xs_jc_bank_internet_info.dept_no = '5006' 
				 
