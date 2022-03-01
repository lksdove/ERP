
        SELECT
        a.the_year,
        a.the_month,
        a.factory_code,
        a.production_line_code,
        a.material_code_product,
        m.material_name,
        a.planned_output_monthly,
        d.work_class_name,
        COALESCE(actual_real.has_production,0) as has_production,
        COALESCE(planned.no_production_scheduled,0) - COALESCE(actual_real_today_end.has_production_today_end,0) as no_production_scheduled,
        a.planned_output_monthly - COALESCE(actual_real.has_production,0) -(COALESCE(planned.no_production_scheduled,0) - COALESCE(actual_real_today_end.has_production_today_end,0)) as schedule_to_made,
        mla.ability_integer * 1.5 as max_ability,
        pcrc_item.item_value as pcrc
        FROM (SELECT
        the_year,
        the_month,
        dept_no as factory_code,
        line_no as production_line_code,
        mtrl_no as material_code_product,
        SUM ( affirm_plan ) AS planned_output_monthly
        FROM
        sc_product_plan_line
        WHERE
--         dept_no = #{factoryCode}
--         and the_year = #{theYear}
--         and the_month = #{theMonth}
--         <if test="productionLineCode != null">
--             and line_no = #{productionLineCode}
--         </if>
--         <if test="materialCodeProduct != null">
--             and mtrl_no = #{materialCodeProduct}
--         </if>
--         AND 
				status = '审核'
        GROUP BY
        the_year,
        the_month,
        dept_no,
        line_no,
        mtrl_no
--         <if test="showZeroPlan != null">
--             HAVING SUM(affirm_plan) > 0
--         </if>
        ) 
				a

        left join (select actual.factory_code,
        actual.production_line_code,
        actual.material_code_product,
				sum(actual.actual_output) as has_production  
				from (SELECT
        a.factory_code,
        a.production_line_code,
        a.material_code_product,
        r1.actual_output
        FROM (SELECT
        the_year,
        the_month,
        dept_no as factory_code,
        line_no as production_line_code,
        mtrl_no as material_code_product,
        SUM ( affirm_plan ) AS planned_output_monthly
        FROM
        sc_product_plan_line
        WHERE
--         dept_no = #{factoryCode}
--         and the_year = #{theYear}
--         and the_month = #{theMonth}
--         <if test="productionLineCode != null">
--             and line_no = #{productionLineCode}
--         </if>
--         <if test="materialCodeProduct != null">
--             and mtrl_no = #{materialCodeProduct}
--         </if>
--         AND 
				status = '审核'
        GROUP BY
        the_year,
        the_month,
        dept_no,
        line_no,
        mtrl_no
--         <if test="showZeroPlan != null">
--             HAVING SUM(affirm_plan) > 0
--         </if>
				)
				a
        left join mes_daily_plan p
        on p.is_valid = '有效' and p.factory_code = a.factory_code and p.production_line_code = a.production_line_code and p.material_code_product = a.material_code_product and EXTRACT(year from p.product_date) = a.the_year and EXTRACT(month from p.product_date) = a.the_month
        join mes_process_order r1
        on r1.daily_plan_no = p.daily_plan_no and r1.is_valid = '有效' and r1.status_output = '已确认' and r1.material_code_product = a.material_code_product) actual
        GROUP BY actual.factory_code,
        actual.production_line_code,
        actual.material_code_product) actual_real
        on actual_real.factory_code = a.factory_code and  actual_real.production_line_code = a.production_line_code and actual_real.material_code_product = a.material_code_product
--今天到月底日计划总和
        left join (SELECT
        a.factory_code,
        a.production_line_code,
        a.material_code_product,
        sum(p.planned_output) as no_production_scheduled
        FROM (SELECT
        the_year,
        the_month,
        dept_no as factory_code,
        line_no as production_line_code,
        mtrl_no as material_code_product,
        SUM ( affirm_plan ) AS planned_output_monthly
        FROM
        sc_product_plan_line
        WHERE
--         dept_no = #{factoryCode}
--         and the_year = #{theYear}
--         and the_month = #{theMonth}
--         <if test="productionLineCode != null">
--             and line_no = #{productionLineCode}
--         </if>
--         <if test="materialCodeProduct != null">
--             and mtrl_no = #{materialCodeProduct}
--         </if>
--         AND 
				status = '审核'
        GROUP BY
        the_year,
        the_month,
        dept_no,
        line_no,
        mtrl_no
--         <if test="showZeroPlan != null">
--             HAVING SUM(affirm_plan) > 0
--         </if>
				)
				a

        left join mes_daily_plan p
        on p.is_valid = '有效' and p.factory_code = a.factory_code and p.production_line_code = a.production_line_code and p.material_code_product = a.material_code_product and EXTRACT(year from p.		product_date) = a.the_year and EXTRACT(month from p.product_date) = a.the_month
        and EXTRACT(day from p.product_date) >= 29
        GROUP BY
        a.factory_code,
        a.production_line_code,
        a.material_code_product) planned
        on planned.factory_code = a.factory_code and planned.production_line_code = a.production_line_code and planned.material_code_product = a.material_code_product
--今天及月底已生产量总和
left join (select actual.factory_code,
        actual.production_line_code,
        actual.material_code_product,
				sum(actual.actual_output) as has_production_today_end 
				from (SELECT
        a.factory_code,
        a.production_line_code,
        a.material_code_product,
        r1.actual_output
        FROM (SELECT
        the_year,
        the_month,
        dept_no as factory_code,
        line_no as production_line_code,
        mtrl_no as material_code_product,
        SUM ( affirm_plan ) AS planned_output_monthly
        FROM
        sc_product_plan_line
        WHERE
--         dept_no = #{factoryCode}
--         and the_year = #{theYear}
--         and the_month = #{theMonth}
--         <if test="productionLineCode != null">
--             and line_no = #{productionLineCode}
--         </if>
--         <if test="materialCodeProduct != null">
--             and mtrl_no = #{materialCodeProduct}
--         </if>
--         AND 
				status = '审核'
        GROUP BY
        the_year,
        the_month,
        dept_no,
        line_no,
        mtrl_no
--         <if test="showZeroPlan != null">
--             HAVING SUM(affirm_plan) > 0
--         </if>
				)
				a
        left join mes_daily_plan p
        on p.is_valid = '有效' and p.factory_code = a.factory_code and p.production_line_code = a.production_line_code and p.material_code_product = a.material_code_product and EXTRACT(year from p.product_date) = a.the_year and EXTRACT(month from p.product_date) = a.the_month and EXTRACT(day from p.product_date) >= 29
        join mes_process_order r1
        on r1.daily_plan_no = p.daily_plan_no and r1.is_valid = '有效' and r1.status_output = '已确认' and r1.material_code_product = a.material_code_product) actual
        GROUP BY actual.factory_code,
        actual.production_line_code,
        actual.material_code_product) actual_real_today_end
        on actual_real_today_end.factory_code = a.factory_code and  actual_real_today_end.production_line_code = a.production_line_code and actual_real_today_end.material_code_product = a.material_code_product



        left join (select item_code as work_class_name from mes_dictionary_item where classification = 'MES班次' and is_valid = '有效') d
        on d.work_class_name is not null

        left join mdm_material m
        on a.material_code_product = m.material_code and m.is_valid = '有效'
        left join mes_dictionary_item ditem
        on ditem.classification = '无产能物料' and ditem.item_code = a.material_code_product and ditem.is_valid = '有效'
        left join mdm_material_classification mmc
        ON ditem.id is null and mmc.material_code = a.material_code_product and mmc.is_valid = '有效'
        left join mdm_classification mc
        ON mc.classification_type = '055' and mc.classification_level = 2 and mc.classification_code =
        mmc.classification_code and mc.is_valid = '有效'
        left join mes_line_ability mla
        on mla.factory_code = a.factory_code and mla.production_line_code =a.production_line_code and mla.ability_type =
        mc.classification_code and mla.is_valid= '有效'
        left join mes_dictionary_item pcrc_item on pcrc_item.classification = '排产容差' and pcrc_item.is_valid = '有效'
        where case when ditem.id is null then mla.ability_integer is not null else 1=1 end
				and a.the_year = 2021
				and a.the_month = 7
        and a.factory_code = '2000'
				and a.production_line_code = 'GZ002'
        ORDER BY
        a.the_year,
        a.the_month,
        a.factory_code,
        a.production_line_code,
        a.material_code_product,
        d.work_class_name