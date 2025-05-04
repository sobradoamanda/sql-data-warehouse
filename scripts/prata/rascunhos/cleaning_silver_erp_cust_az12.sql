SELECT cid,
       bdate,
       gen
FROM bronze.erp_cust_az12
WHERE cid like '%AW00011000%'


SELECT * FROM prata.crm_cust_info;

SELECT
CASE WHEN cid LIKE 'NAS%' THEN substring(cid, 4, LEN(cid))
	ELSE cid 
	END AS cid,
       bdate,
       gen
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN substring(cid, 4, LEN(cid))
	ELSE cid 
	END NOT IN (SELECT DISTINCT cst_key FROM prata.crm_cust_info);


-- datas

SELECT bdate FROM prata.erp_cust_az12
WHERE bdate < '1924-01-01' or bdate > getdate()

-- genero

SELECT DISTINCT gen FROM bronze.erp_cust_az12 

SELECT DISTINCT 
CASE WHEN UPPER(trim(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(trim(gen)) IN ('M', 'MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen 
FROM bronze.erp_cust_az12 

SELECT DISTINCT gen FROM prata.erp_cust_az12;

-- Ajustando as colunas

INSERT INTO prata. erp_cust_az12 (cid, bdate, gen)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN substring(cid, 4, LEN(cid))
	ELSE cid 
	END AS cid,
CASE WHEN bdate > GETDATE() THEN NULL
	 ELSE bdate
END AS bdate,
CASE WHEN UPPER(trim(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(trim(gen)) IN ('M', 'MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12


select * from prata.erp_cust_az12;