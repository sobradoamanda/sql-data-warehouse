/*
Carregar camada prata (Bronze -> Prata)

    EXEC Prata.load_prata;

*/

CREATE OR ALTER PROCEDURE prata.load_prata AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Carregando Camada Prata';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Carregando tabelas de CRM';
		PRINT '------------------------------------------------';

		-- Carregando prata.crm_cust_info
        SET @start_time = GETDATE();
		PRINT '>> Truncando tabela: prata.crm_cust_info';
		TRUNCATE TABLE prata.crm_cust_info;
		PRINT '>> Inserindo dados: prata.crm_cust_info';
		INSERT INTO prata.crm_cust_info (
			cst_id, 
			cst_key, 
			cst_firstname, 
			cst_lastname, 
			cst_marital_status, 
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END AS cst_marital_status, 
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END AS cst_gndr, 
			cst_create_date
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) t
		WHERE flag_last = 1; 
		SET @end_time = GETDATE();
        PRINT '>> Dura��o: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

		-- Carregando prata.crm_prd_info
        SET @start_time = GETDATE();
		PRINT '>> Truncando tabela: prata.crm_prd_info';
		TRUNCATE TABLE prata.crm_prd_info;
		PRINT '>> Inserindo dados: prata.crm_prd_info';
		INSERT INTO prata.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, 
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,        
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,
			CASE 
				WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
				WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
				WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
				WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line, 
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(
				LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
				AS DATE
			) AS prd_end_dt 
		FROM bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Dura��o: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

        -- Carregando crm_sales_details
        SET @start_time = GETDATE();
		PRINT '>> Truncando tabela: prata.crm_sales_details';
		TRUNCATE TABLE prata.crm_sales_details;
		PRINT '>> Inserindo dados: prata.crm_sales_details';
		INSERT INTO prata.crm_sales_details (
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
			CASE 
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE 
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE 
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
					THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales, 
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 
					THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price  
			END AS sls_price
		FROM bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Dura��o: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

        -- Carregando erp_cust_az12
        SET @start_time = GETDATE();
		PRINT '>> Truncando tabela: prata.erp_cust_az12';
		TRUNCATE TABLE prata.erp_cust_az12;
		PRINT '>> Inserindo dados: prata.erp_cust_az12';
		INSERT INTO prata.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		SELECT
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
				ELSE cid
			END AS cid, 
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate, 
			CASE
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END AS gen 
		FROM bronze.erp_cust_az12;
	    SET @end_time = GETDATE();
        PRINT '>> Dura��o: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Carregando ERP Tables';
		PRINT '------------------------------------------------';

        -- Carregando erp_loc_a101
        SET @start_time = GETDATE();
		PRINT '>> Truncando tabela: prata.erp_loc_a101';
		TRUNCATE TABLE prata.erp_loc_a101;
		PRINT '>> Inserindo dados: prata.erp_loc_a101';
		INSERT INTO prata.erp_loc_a101 (
			cid,
			cntry
		)
		SELECT
			REPLACE(cid, '-', '') AS cid, 
			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry 
		FROM bronze.erp_loc_a101;
	    SET @end_time = GETDATE();
        PRINT '>> Dura��o: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';
		
		-- Carregando erp_px_cat_g1v2
		SET @start_time = GETDATE();
		PRINT '>> Truncando tabela: prata.erp_px_cat_g1v2';
		TRUNCATE TABLE prata.erp_px_cat_g1v2;
		PRINT '>> Inserindo dados: prata.erp_px_cat_g1v2';
		INSERT INTO prata.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT '>> Dura��o: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Camada Prata finalizada';
        PRINT '   - Dura��o Total: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' segundos';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'OCORREU UM ERRO DURANTE O CARREGAMENTO'
		PRINT 'Mensagem de erro' + ERROR_MESSAGE();
		PRINT 'Mensagem de erro' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Mensagem de erro' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
