select
a.process_order_no as final_process_order,
a.material_code_product as final_material_code,
mp.base_unit as final_material_unit,
b.factory_code,
b.product_date,
case when cast(to_char(b.product_date + INTERVAL '1 month', 'yyyy-mm') || '-01' as timestamp) - INTERVAL '1 day' = b.product_date
and b.work_class_name = '中班'
then b.product_date + INTERVAL '1 day'
else b.product_date end order_date,
b.work_team_name,
b.work_class_name,
a.work_center_code,
a.actual_output,
ps.product_specification,
--一级展开
cm1.material_code_stuff as material_code_stuff,
ms1.base_unit as material_unit_stuff,
ms1.material_made_type as material_made_type,
case when bw.id is NULL or jwm.id is NULL then null else '是' end as if_weight,
null as if_protein,
sum(cm1.consume_quantity) as actual_consume,
round((a.actual_output/ob1.fundamental_quantity_bom) * ob1.quota_quantity,6) as theortical_consume,
round((a.actual_output/ob1.fundamental_quantity_bom) * ob1.quota_quantity * (1+COALESCE(ob1.loss_rate,0)/100),6) as quota_consume,
sum(voucher1.untax_amount) as actual_money,--实际金额/实际消耗数量 = 单价；单价 * 理论消耗数量 = 理论金额；单价 * 定额消耗数量 = 定额消耗金额
round((sum(voucher1.untax_amount)/sum(cm1.consume_quantity)) * (a.actual_output/ob1.fundamental_quantity_bom) * ob1.quota_quantity,6) as theortical_money,
round((sum(voucher1.untax_amount)/sum(cm1.consume_quantity)) * (a.actual_output/ob1.fundamental_quantity_bom) * ob1.quota_quantity * (1+COALESCE(ob1.loss_rate,0)/100),6) as quota_money

--主数据
from mes_process_order a
join mdm_material mp
on mp.material_code = a.material_code_product and mp.is_valid = '有效' and mp.material_type in
('FERT','VERP','ROH')
LEFT join mdm_product_specification ps
on ps.product_specification_code = mp.specification and ps.is_valid = '有效'
join mes_work_order b
on a.work_order_no = b.work_order_no and b.is_valid = '有效'
left join (SELECT
					a.id,
					a.material_code_bottle,
					a.work_center_code,
					a.bottle_weight,
					a.loss_rate
					FROM "mes_bottle_weight" a
					where a.factory_code = '2511'
					and a.valid_begin <= NOW()
					and a.valid_end >= NOW()
					and a.is_valid = '有效'
					and a.status = '审核'
					and NOT EXISTS (select id from mes_bottle_weight b
					where
					b.valid_begin <= NOW()
					and b.valid_end >= NOW()
					and a.factory_code = b.factory_code
					and a.material_code_bottle = b.material_code_bottle
					and a.work_center_code = b.work_center_code
					and a.valid_begin < b.valid_begin)) as bw
on bw.material_code_bottle = a.material_code_product and bw.work_center_code = a.work_center_code
--一级展开表
join mes_consume_material cm1
on cm1.process_order_no = a.process_order_no and cm1.is_valid = '有效'
join mdm_material ms1
on ms1.material_code = cm1.material_code_stuff and ms1.is_valid = '有效'
left join mes_order_bom ob1
on ob1.process_order_no = cm1.process_order_no and ob1.material_code_stuff = cm1.material_code_stuff and
ob1.is_valid = '有效'
left join wms_matnr_voucher_item voucher1
on voucher1.voucher_code = a.consume_document and voucher1.matnr = cm1.material_code_stuff and voucher1.factory = b.factory_code
and voucher1.stock_place = cm1.warehouse_code_out and voucher1.batch_number = cm1.batch_stuff
left join mes_jckh_weight_material jwm
on jwm.weight_material_code = cm1.material_code_stuff and jwm.is_valid = '有效'

where a.is_valid = '有效'
and a.actual_output > 0
and a.status_consume = '已确认'
and b.factory_code = '2511'
and b.product_date = '2020-12-08'

GROUP BY 
a.process_order_no,
a.material_code_product,
mp.base_unit,
b.factory_code,
b.product_date,
b.work_class_name,
b.work_team_name,
b.work_class_name,
a.work_center_code,
a.actual_output,
ps.product_specification,
cm1.material_code_stuff,
ms1.base_unit,
ms1.material_made_type,
bw.id,
jwm.id,
ob1.fundamental_quantity_bom,
ob1.quota_quantity,
ob1.loss_rate

				
union all


select
a.process_order_no as final_process_order,
a.material_code_product as final_material_code,
mp.base_unit as final_material_unit,
b.factory_code,
b.product_date,
case when cast(to_char(b.product_date + INTERVAL '1 month', 'yyyy-mm') || '-01' as timestamp) - INTERVAL '1 day' = b.product_date and b.work_class_name = '中班'
then b.product_date + INTERVAL '1 day' else b.product_date end order_date,
b.work_team_name,
b.work_class_name,
a.work_center_code,
a.actual_output,
ps.product_specification,
--二级展开
cm2.material_code_stuff as material_code_stuff,
ms2.base_unit as material_unit_stuff,
ms2.material_made_type as material_made_type,
null as if_weight,
case when protein.id is NULL or proteinjckh.id is NULL then null else '是' end as if_protein,
round(sum(cm2.consume_quantity * (cm2.consume_quantity/os2.actual_output)),6) as actual_consume,
round(sum((order2.actual_output/ob2.fundamental_quantity_bom) * ob2.quota_quantity * (cm2.consume_quantity/os2.actual_output)),6) as theortical_consume,
round(sum((order2.actual_output/ob2.fundamental_quantity_bom) * ob2.quota_quantity *(1+COALESCE(ob1.loss_rate,0)/100) * (cm2.consume_quantity/os2.actual_output)),6) as quota_consume,
sum(voucher2.untax_amount) as actual_money,--实际金额/实际消耗数量 = 单价；单价 * 理论消耗数量 = 理论金额；单价 * 定额消耗数量 = 定额消耗金额
round(sum((voucher2.untax_amount / (cm2.consume_quantity * (cm2.consume_quantity/os2.actual_output))) * ((order2.actual_output/ob2.fundamental_quantity_bom) * ob2.quota_quantity * (cm2.consume_quantity/os2.actual_output))),6) as theortical_money,
round(sum((voucher2.untax_amount / (cm2.consume_quantity * (cm2.consume_quantity/os2.actual_output))) * ((order2.actual_output/ob2.fundamental_quantity_bom) * ob2.quota_quantity *(1+COALESCE(ob1.loss_rate,0)/100) * (cm2.consume_quantity/os2.actual_output))),6) as quota_money
--主数据
from mes_process_order a
join mdm_material mp
on mp.material_code = a.material_code_product and mp.is_valid = '有效' and mp.material_type in
('FERT','VERP','ROH')
LEFT join mdm_product_specification ps
on ps.product_specification_code = mp.specification and ps.is_valid = '有效'
join mes_work_order b
on a.work_order_no = b.work_order_no and b.is_valid = '有效'
left join (SELECT
a.id,
a.material_code_bottle,
a.work_center_code,
a.bottle_weight,
a.loss_rate
FROM "mes_bottle_weight" a
where a.factory_code = '2511'
and a.valid_begin <= NOW()
and a.valid_end >= NOW()
and a.is_valid = '有效'
and a.status = '审核'
and NOT EXISTS (select id from mes_bottle_weight b
where
b.valid_begin <= NOW()
and b.valid_end >= NOW()
and a.factory_code = b.factory_code
and a.material_code_bottle = b.material_code_bottle
and a.work_center_code = b.work_center_code
and a.valid_begin < b.valid_begin)) as bw
on bw.material_code_bottle = a.material_code_product and bw.work_center_code = a.work_center_code
--一级展开表
left join mes_consume_material cm1
on cm1.process_order_no = a.process_order_no and cm1.is_valid = '有效'
left join mdm_material ms1
on ms1.material_code = cm1.material_code_stuff and ms1.is_valid = '有效'
left join mes_order_bom ob1
on ob1.process_order_no = cm1.process_order_no and ob1.material_code_stuff = cm1.material_code_stuff and
ob1.is_valid = '有效'
left join wms_matnr_voucher_item voucher1
on voucher1.voucher_code = a.consume_document and voucher1.matnr = cm1.material_code_stuff and voucher1.factory
= b.factory_code
and voucher1.stock_place = cm1.warehouse_code_out and voucher1.batch_number = cm1.batch_stuff
left join mes_output_semi os
on os.batch = cm1.batch_stuff and os.is_valid = '有效' and os.status = '已确认'
left join mes_jckh_weight_material jwm
on jwm.weight_material_code = cm1.material_code_stuff and jwm.is_valid = '有效'
left join (SELECT
a.id,
a.slurry_code,
a.assess_type,
a.protein_whey,
a.protein_whole_fat,
a.protein_defat,
a.protein_total
FROM "mes_jckh_slurry_protein" a
where a.valid_begin <= NOW()
and a.valid_end >= NOW()
and a.is_valid = '有效'
and NOT EXISTS (select id from mes_jckh_slurry_protein b
where
b.valid_begin <= NOW()
and b.is_valid = '有效'
and b.valid_end >= NOW()
and a.slurry_code = b.slurry_code
and a.valid_begin < b.valid_begin)) as protein
on protein.slurry_code = cm1.material_code_stuff
--二级展开表
join mes_consume_material cm2
on cm2.process_order_no = os.process_order_no and ms1.material_made_type in ('BLJ','BPG') and cm2.is_valid =
'有效'
left join mes_process_order order2
on order2.process_order_no = cm2.process_order_no and order2.is_valid = '有效'
left join mes_work_order work2
on order2.work_order_no = work2.work_order_no and work2.is_valid = '有效'
left join mdm_material ms2
on ms2.material_code = cm2.material_code_stuff and ms2.is_valid = '有效'
left join mes_order_bom ob2
on ob2.process_order_no = cm2.process_order_no and ob2.material_code_stuff = cm2.material_code_stuff and
ob2.is_valid = '有效'
left join wms_matnr_voucher_item voucher2
on voucher2.voucher_code = order2.consume_document and voucher2.matnr = cm2.material_code_stuff and
voucher2.factory = work2.factory_code
and voucher2.stock_place = cm2.warehouse_code_out and voucher2.batch_number = cm2.batch_stuff
left join mes_output_semi os2
on os2.batch = cm2.batch_stuff and os2.is_valid = '有效' and os2.status = '已确认'
left join mes_jckh_protein_material proteinjckh
on proteinjckh.protein_material_code = cm2.material_code_stuff and proteinjckh.is_valid = '有效'

where a.is_valid = '有效'
and a.actual_output > 0
and a.status_consume = '已确认'
and b.factory_code = '2511'
and b.product_date = '2020-12-08'

GROUP BY 
a.process_order_no,
a.material_code_product,
mp.base_unit,
b.factory_code,
b.product_date,
b.work_team_name,
b.work_class_name,
a.work_center_code,
a.actual_output,
ps.product_specification,
cm2.material_code_stuff,
ms2.base_unit,
ms2.material_made_type,
protein.id,
proteinjckh.id

union all

select
a.process_order_no as final_process_order,
a.material_code_product as final_material_code,
mp.base_unit as final_material_unit,
b.factory_code,
b.product_date,
case when cast(to_char(b.product_date + INTERVAL '1 month', 'yyyy-mm') || '-01' as timestamp) - INTERVAL '1 day'
= b.product_date
and b.work_class_name = '中班'
then b.product_date + INTERVAL '1 day'
else b.product_date end order_date,
b.work_team_name,
b.work_class_name,
a.work_center_code,
a.actual_output,
ps.product_specification,
--三级展开
cm3.material_code_stuff as material_code_stuff,
ms3.base_unit as material_unit_stuff,
ms3.material_made_type as material_made_type,
null as if_weight,
null as if_protein,
round(sum(cm3.consume_quantity * (cm3.consume_quantity/os3.actual_output)),6) as actual_consume,
round(sum((order3.actual_output/ob3.fundamental_quantity_bom) * ob3.quota_quantity * (cm3.consume_quantity/os3.actual_output)),6) as theortical_consume,
round(sum((order3.actual_output/ob3.fundamental_quantity_bom) * ob3.quota_quantity * (1+COALESCE(ob2.loss_rate,0)/100) * (cm3.consume_quantity/os3.actual_output)),6) as quota_consume,
round(sum(voucher3.untax_amount),6) as actual_money,--实际金额/实际消耗数量 = 单价；单价 * 理论消耗数量 = 理论金额；单价 * 定额消耗数量 = 定额消耗金额
round(sum((voucher3.untax_amount / (cm3.consume_quantity * (cm3.consume_quantity/os3.actual_output))) * ((order3.actual_output/ob3.fundamental_quantity_bom) * ob3.quota_quantity * (cm3.consume_quantity/os3.actual_output))),6) as theortical_money,
round(sum((voucher3.untax_amount / (cm3.consume_quantity * (cm3.consume_quantity/os3.actual_output))) * ((order3.actual_output/ob3.fundamental_quantity_bom) * ob3.quota_quantity * (1+COALESCE(ob2.loss_rate,0)/100) * (cm3.consume_quantity/os3.actual_output))),6) as quota_money
--主数据
from mes_process_order a
join mdm_material mp
on mp.material_code = a.material_code_product and mp.is_valid = '有效' and mp.material_type in
('FERT','VERP','ROH')
LEFT join mdm_product_specification ps
on ps.product_specification_code = mp.specification and ps.is_valid = '有效'
join mes_work_order b
on a.work_order_no = b.work_order_no and b.is_valid = '有效'
left join (SELECT
a.id,
a.material_code_bottle,
a.work_center_code,
a.bottle_weight,
a.loss_rate
FROM "mes_bottle_weight" a
where a.factory_code = '2511'
and a.valid_begin <= NOW()
and a.valid_end >= NOW()
and a.is_valid = '有效'
and a.status = '审核'
and NOT EXISTS (select id from mes_bottle_weight b
where
b.valid_begin <= NOW()
and b.valid_end >= NOW()
and a.factory_code = b.factory_code
and a.material_code_bottle = b.material_code_bottle
and a.work_center_code = b.work_center_code
and a.valid_begin < b.valid_begin)) as bw
on bw.material_code_bottle = a.material_code_product and bw.work_center_code = a.work_center_code
--一级展开表
join mes_consume_material cm1
on cm1.process_order_no = a.process_order_no and cm1.is_valid = '有效'
left join mdm_material ms1
on ms1.material_code = cm1.material_code_stuff and ms1.is_valid = '有效'
left join mes_order_bom ob1
on ob1.process_order_no = cm1.process_order_no and ob1.material_code_stuff = cm1.material_code_stuff and
ob1.is_valid = '有效'
left join wms_matnr_voucher_item voucher1
on voucher1.voucher_code = a.consume_document and voucher1.matnr = cm1.material_code_stuff and voucher1.factory
= b.factory_code
and voucher1.stock_place = cm1.warehouse_code_out and voucher1.batch_number = cm1.batch_stuff
left join mes_output_semi os
on os.batch = cm1.batch_stuff and os.is_valid = '有效' and os.status = '已确认'
left join mes_jckh_weight_material jwm
on jwm.weight_material_code = cm1.material_code_stuff and jwm.is_valid = '有效'
left join (SELECT
a.id,
a.slurry_code,
a.assess_type,
a.protein_whey,
a.protein_whole_fat,
a.protein_defat,
a.protein_total
FROM "mes_jckh_slurry_protein" a
where a.valid_begin <= NOW()
and a.valid_end >= NOW()
and a.is_valid = '有效'
and NOT EXISTS (select id from mes_jckh_slurry_protein b
where
b.valid_begin <= NOW()
and b.is_valid = '有效'
and b.valid_end >= NOW()
and a.slurry_code = b.slurry_code
and a.valid_begin < b.valid_begin)) as protein
on protein.slurry_code = cm1.material_code_stuff
--二级展开表
join mes_consume_material cm2
on cm2.process_order_no = os.process_order_no and ms1.material_made_type in ('BLJ','BPG') and cm2.is_valid =
'有效'
left join mes_process_order order2
on order2.process_order_no = cm2.process_order_no and order2.is_valid = '有效'
left join mes_work_order work2
on order2.work_order_no = work2.work_order_no and work2.is_valid = '有效'
left join mdm_material ms2
on ms2.material_code = cm2.material_code_stuff and ms2.is_valid = '有效'
left join mes_order_bom ob2
on ob2.process_order_no = cm2.process_order_no and ob2.material_code_stuff = cm2.material_code_stuff and
ob2.is_valid = '有效'
join wms_matnr_voucher_item voucher2
on voucher2.voucher_code = order2.consume_document and voucher2.matnr = cm2.material_code_stuff and
voucher2.factory = work2.factory_code
and voucher2.stock_place = cm2.warehouse_code_out and voucher2.batch_number = cm2.batch_stuff
left join mes_output_semi os2
on os2.batch = cm2.batch_stuff and os2.is_valid = '有效' and os2.status = '已确认'
left join mes_jckh_protein_material proteinjckh
on proteinjckh.protein_material_code = cm2.material_code_stuff and proteinjckh.is_valid = '有效'
--三级展开表
join mes_consume_material cm3
on cm3.process_order_no = os2.process_order_no and ms2.material_made_type = 'BLJ' and cm3.is_valid = '有效'
left join mes_process_order order3
on order3.process_order_no = cm3.process_order_no and order3.is_valid = '有效'
left join mes_work_order work3
on order3.work_order_no = work3.work_order_no and work3.is_valid = '有效'
left join mdm_material ms3
on ms3.material_code = cm3.material_code_stuff and ms3.is_valid = '有效'
left join mes_order_bom ob3
on ob3.process_order_no = cm3.process_order_no and ob3.material_code_stuff = cm3.material_code_stuff and
ob3.is_valid = '有效'
left join wms_matnr_voucher_item voucher3
on voucher3.voucher_code = order3.consume_document and voucher3.matnr = cm3.material_code_stuff and
voucher3.factory = work3.factory_code
and voucher3.stock_place = cm3.warehouse_code_out and voucher3.batch_number = cm3.batch_stuff
left join mes_output_semi os3
on os3.batch = cm3.batch_stuff and ms3.material_made_type = 'BLJ' and os3.is_valid = '有效' and os3.status = '已确认'

where a.is_valid = '有效'
and a.actual_output > 0
and a.status_consume = '已确认'
and b.factory_code = '2511'
and b.product_date = '2020-12-08'

GROUP BY 
a.process_order_no,
a.material_code_product,
mp.base_unit,
b.factory_code,
b.product_date,
b.work_team_name,
b.work_class_name,
a.work_center_code,
a.actual_output,
ps.product_specification,
cm3.material_code_stuff,
ms3.base_unit,
ms3.material_made_type

