--exec bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
;		PRINT '=========================='
		PRINT 'Carregando a camada bronze'
		PRINT '=========================='

		PRINT 'Carregando tabelas de CRM'

		SET @start_time = GETDATE(); 
		PRINT'>> Truncando tabela: bronze.crm_cust_info'
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT'>> Inserindo dados na tabela: bronze.crm_cust_info'
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Amanda\DE_Project - youtube\sql-data-warehouse\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE(); 
		PRINT '>> Tempo de carregamento:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos'

		SET @start_time = GETDATE(); 
		PRINT'>> Truncando tabela: bronze.crm_prd_info'
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT'>> Inserindo dados na tabela: bronze.crm_prd_info'
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Amanda\DE_Project - youtube\sql-data-warehouse\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE(); 
		PRINT '>> Tempo de carregamento:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos'


		SET @start_time = GETDATE(); 
		PRINT'>> Truncando tabela: bronze.crm_sales_details'
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT'>> Inserindo dados na tabela: bronze.crm_sales_details'
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Amanda\DE_Project - youtube\sql-data-warehouse\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE(); 
		PRINT '>> Tempo de carregamento:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos'

		PRINT 'Carregando tabelas de ERP'

		SET @start_time = GETDATE(); 
		PRINT'>> Truncando tabela: bronze.erp_cust_az12'
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT'>> Inserindo dados na tabela: bronze.erp_cust_az12'
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Amanda\DE_Project - youtube\sql-data-warehouse\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE(); 
		PRINT '>> Tempo de carregamento:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos'

		SET @start_time = GETDATE(); 
		PRINT'>> Truncando tabela: bronze.erp_loc_a101'
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT'>> Inserindo dados na tabela: bronze.erp_loc_a101'
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Amanda\DE_Project - youtube\sql-data-warehouse\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE(); 
		PRINT '>> Tempo de carregamento:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos'

		SET @start_time = GETDATE(); 
		PRINT'>> Truncando tabela: bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT'>> Inserindo dados na tabela: bronze.erp_px_cat_g1v2'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Amanda\DE_Project - youtube\sql-data-warehouse\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE(); 
		PRINT '>> Tempo de carregamento:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos'

		SET @batch_END_time = GETDATE();
		PRINT '=========================='
		PRINT 'Carregamento finalizado'
		PRINT 'Tempo total de carregamento: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' segundos';
		PRINT '=========================='
	END TRY
	BEGIN CATCH
		PRINT '===================================================='
		PRINT 'OCORREU UM ERRO AO CARREGAR A CAMADA BRONZE'
		PRINT 'Mensagem de erro: ' + ERROR_MESSAGE();
		PRINT 'Mensagem de erro: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Mensagem de erro: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '===================================================='
	END CATCH
END