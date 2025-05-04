SELECT * FROM bronze.crm_sales_details;

-- Verificando espa�os 

SELECT * FROM prata.crm_sales_details
WHERE sls_ord_num ! = TRIM(sls_ord_num);


SELECT * FROM prata.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key from prata.crm_prd_info);

SELECT * FROM prata.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id from prata.crm_cust_info);


-- Transformar inteiros em data

SELECT sls_order_dt FROM prata.crm_sales_details
WHERE sls_order_dt <= 0;

SELECT NULLIF(sls_order_dt,0) FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 OR sls_order_dt > 20260101;

SELECT NULLIF(sls_order_dt,0) FROM bronze.crm_sales_details
WHERE sls_order_dt < 19000101 OR sls_order_dt > 20260101;

--
SELECT sls_ship_dt FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0;

SELECT NULLIF(sls_ship_dt,0) FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 OR sls_ship_dt > 20260101;

SELECT NULLIF(sls_ship_dt,0) FROM bronze.crm_sales_details
WHERE sls_ship_dt < 19000101 OR sls_ship_dt > 20260101;

--
SELECT sls_due_dt FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0;

SELECT NULLIF(sls_due_dt,0) FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 OR sls_due_dt > 20260101;

SELECT NULLIF(sls_due_dt,0) FROM bronze.crm_sales_details
WHERE sls_due_dt < 19000101 OR sls_due_dt > 20260101;

-- Checando por order dates inv�lidas 

SELECT *
FROM prata.crm_sales_details
WHERE sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt;

-- Inconsist�ncias nas vendas
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales,	sls_quantity,	sls_price;

SELECT DISTINCT
	sls_sales AS old_sls_sales,
	sls_quantity,
	sls_price AS old_sls_price,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
		THEN sls_quantity * ABS(sls_price) 
		ELSE sls_sales
	END AS sls_sales,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
		THEN sls_sales / NULLIF(sls_quantity,0)
		ELSE sls_price
	END AS sls_price

FROM prata.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales,	sls_quantity,	sls_price;

  -- Ajustando colunas para inser��o de dados nas tabelas

INSERT INTO prata.crm_sales_details(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price

)
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE)
	END AS sls_due_dt,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
		THEN sls_quantity * ABS(sls_price) 
	ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
		THEN sls_sales / NULLIF(sls_quantity,0)
	ELSE sls_price
	END AS sls_price
  FROM bronze.crm_sales_details;


 SELECT * FROM prata.crm_sales_details