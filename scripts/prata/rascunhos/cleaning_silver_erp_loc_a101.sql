
SELECT 
	cid, 
	cntry
FROM bronze.erp_loc_a101;


SELECT cst_key FROM prata.crm_cust_info

SELECT DISTINCT 
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	 WHEN TRIM(cntry) = '' or cntry IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101;

SELECT DISTINCT cntry
FROM prata.erp_loc_a101

-- Ajustando colunas

INSERT INTO prata.erp_loc_a101 (cid, cntry)
SELECT 
	REPLACE(cid, '-','') cid, 
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	 WHEN TRIM(cntry) = '' or cntry IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101;


SELECT * FROM prata.erp_loc_a101;