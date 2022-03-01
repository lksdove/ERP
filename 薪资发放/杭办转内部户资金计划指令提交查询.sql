--:ai_xs_bank_id   1  PB销售公司 ->  属性性质
--:ai_bank_id      2  杭办账号
SELECT
	hcmerp_yw_berweisung_list.xuhao,
	hcmerp_yw_berweisung_list.curr_type,
	hcmerp_yw_berweisung_list.customer_no,
	mdm_company.company_name,
	hcmerp_yw_berweisung_list.rem_money,
	hcmerp_yw_berweisung_list.project_content,
	hcmerp_yw_berweisung_list.note,
	hcmerp_yw_berweisung_list.confirm_money,
	xs_jc_bank_internet_info.account_no,
	xs_jc_bank_internet_info.account_name_cn,
	xs_jc_bank_internet_info.bank_full_name,
	hcmerp_yw_berweisung_list.dept_no,
	xscompany.company_name AS sale_company_name,
	company_pianqu.area_name,
	hcmerp_yw_berweisung_list.ka_no,
	hcmerp_yw_berweisung_list.ka_status,
	hcmerp_yw_berweisung_list.ka_owner,
	hcmerp_yw_berweisung_list.ka_bank_name,
	hcmerp_yw_berweisung_list.status,
	hcmerp_yw_berweisung_list.commit_time,
	hcmerp_yw_berweisung_list.operate_time,
	hcmerp_yw_berweisung_list.pay_fseqno,
	hcmerp_yw_berweisung_list.return_paytime,
	hcmerp_yw_berweisung_list.oper_people,
	hcmerp_yw_berweisung_list.return_paytxt,
	hcmerp_yw_berweisung_list.return_paymoney,
	xs_jc_bank_internet_info.the_status,
	hcmerp_yw_berweisung_list.yx_status,
	hcmerp_yw_berweisung_list.trans_code,
	hcmerp_yw_berweisung_list.trans_type,
	hcmerp_yw_berweisung_list.ka_city_name,
	fund_jc_icbc_website_info.paysysbnkcode,
	fund_jc_icbc_website_info.bnkname,
	hcmerp_yw_berweisung_list.our_bank_id 
FROM
	xs_jc_bank_internet_info,
	mdm_company,
	mdm_company xscompany,
	(
	SELECT
		mdm_company_base.company_code,
		mdm_area.area_name 
	FROM
		mdm_company_base,
		mdm_base_area,
		mdm_area 
	WHERE
		mdm_company_base.base_code = mdm_base_area.base_code 
		AND mdm_base_area.area_code = mdm_area.area_code 
	) company_pianqu,
	hcmerp_yw_berweisung_list
	LEFT OUTER JOIN fund_jc_icbc_website_info ON ( hcmerp_yw_berweisung_list.bank_serial = fund_jc_icbc_website_info.bank_serial ) 
WHERE
	( hcmerp_yw_berweisung_list.our_bank_id = xs_jc_bank_internet_info.bank_id ) 
	AND ( hcmerp_yw_berweisung_list.customer_no = mdm_company.company_code ) 
	AND ( hcmerp_yw_berweisung_list.dept_no = xscompany.company_code ) 
	AND ( hcmerp_yw_berweisung_list.customer_no = company_pianqu.company_code ) 
	AND 
	(
		( hcmerp_yw_berweisung_list.data_fee_source = '内部户转账' ) 
-- 		AND ( hcmerp_yw_berweisung_list.our_bank_id = #hzAccount# ) 
-- 		AND (
-- 			hcmerp_yw_berweisung_list.our_bank_id IN ( SELECT bank_id FROM xs_jc_bank_internet_info WHERE belong_company IN ( SELECT dept_no FROM xs_jc_bank_internet_info WHERE bank_id = #bankId# ) AND bank_id <> #bankId# ) 
-- 		) 
-- 		AND ( hcmerp_yw_berweisung_list.pay_month >= #startDate#::DATE ) 
-- 		AND ( hcmerp_yw_berweisung_list.pay_month < #endDate#:: DATE + INTERVAL '1 day' ) 
		AND ( xs_jc_bank_internet_info.the_status <> '无效' ) 
-- 		AND ( hcmerp_yw_berweisung_list.status in $status$ ) 
		AND ( hcmerp_yw_berweisung_list.status IN ( '二审', '提交' ) ) 
		AND ( hcmerp_yw_berweisung_list.trans_type = '支付' ) 
	) 
	AND 1 <> 0 
	
	UNION
SELECT
	hcmerp_yw_berweisung_list.xuhao,
	hcmerp_yw_berweisung_list.curr_type,
	hcmerp_yw_berweisung_list.customer_no,
	mdm_company.company_name,
	hcmerp_yw_berweisung_list.rem_money,
	hcmerp_yw_berweisung_list.project_content,
	hcmerp_yw_berweisung_list.note,
	hcmerp_yw_berweisung_list.confirm_money,
	xs_jc_bank_internet_info.account_no,
	xs_jc_bank_internet_info.account_name_cn,
	xs_jc_bank_internet_info.bank_full_name,
	hcmerp_yw_berweisung_list.dept_no,
	xscompany.company_name AS sale_company_name,
	company_pianqu.area_name,
	hcmerp_yw_berweisung_list.ka_no,
	hcmerp_yw_berweisung_list.ka_status,
	hcmerp_yw_berweisung_list.ka_owner,
	hcmerp_yw_berweisung_list.ka_bank_name,
	hcmerp_yw_berweisung_list.status,
	hcmerp_yw_berweisung_list.commit_time,
	hcmerp_yw_berweisung_list.operate_time,
	hcmerp_yw_berweisung_list.pay_fseqno,
	hcmerp_yw_berweisung_list.return_paytime,
	hcmerp_yw_berweisung_list.oper_people,
	hcmerp_yw_berweisung_list.return_paytxt,
	hcmerp_yw_berweisung_list.return_paymoney,
	xs_jc_bank_internet_info.the_status,
	hcmerp_yw_berweisung_list.yx_status,
	hcmerp_yw_berweisung_list.trans_code,
	hcmerp_yw_berweisung_list.trans_type,
	hcmerp_yw_berweisung_list.ka_city_name,
	fund_jc_icbc_website_info.paysysbnkcode,
	fund_jc_icbc_website_info.bnkname,
	hcmerp_yw_berweisung_list.our_bank_id 
FROM
	xs_jc_bank_internet_info,
	mdm_company,
	mdm_company xscompany,
	(
	SELECT
		mdm_company_base.company_code,
		mdm_area.area_name 
	FROM
		mdm_company_base,
		mdm_base_area,
		mdm_area 
	WHERE
		mdm_company_base.base_code = mdm_base_area.base_code 
		AND mdm_base_area.area_code = mdm_area.area_code 
	) company_pianqu,
	hcmerp_yw_berweisung_list
	LEFT OUTER JOIN fund_jc_icbc_website_info ON ( hcmerp_yw_berweisung_list.bank_serial = fund_jc_icbc_website_info.bank_serial ) 
WHERE
	( hcmerp_yw_berweisung_list.our_bank_id = xs_jc_bank_internet_info.bank_id ) 
	AND ( hcmerp_yw_berweisung_list.customer_no = mdm_company.company_code ) 
	AND ( hcmerp_yw_berweisung_list.dept_no = xscompany.company_code ) 
	AND ( hcmerp_yw_berweisung_list.customer_no = company_pianqu.company_code ) 
	AND (
		( hcmerp_yw_berweisung_list.data_fee_source = '内部户转账' ) 
		AND (
			hcmerp_yw_berweisung_list.our_bank_id IN ( SELECT bank_id FROM xs_jc_bank_internet_info WHERE belong_company IN ( SELECT dept_no FROM xs_jc_bank_internet_info WHERE bank_id = #bankId# ) AND bank_id <> #bankId# ) 
		) 
-- 		AND ( hcmerp_yw_berweisung_list.pay_month >= #startDate#::DATE ) 
-- 		AND ( hcmerp_yw_berweisung_list.pay_month < #endDate#:: DATE + INTERVAL '1 day' ) 
		AND ( xs_jc_bank_internet_info.the_status <> '无效' ) 
-- 		AND ( hcmerp_yw_berweisung_list.status in $status$ ) 
		AND ( hcmerp_yw_berweisung_list.status IN ( '二审', '提交' ) ) 
		AND ( hcmerp_yw_berweisung_list.trans_type = '支付' ) 
	) 
	AND 0 = 0
	
	

	( SELECT bank_id FROM xs_jc_bank_internet_info WHERE belong_company IN ( SELECT dept_no FROM xs_jc_bank_internet_info 
	WHERE bank_id = 2
	) 
	AND bank_id <> 2
	) 