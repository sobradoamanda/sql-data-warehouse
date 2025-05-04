-- Buscando valores nulos ou duplicados

SELECT * FROM prata.crm_prd_info;

-- Verificando se temos chaves primárias duplicadas
SELECT 
	prd_id,
	count(*)
FROM prata.crm_prd_info
GROUP BY prd_id
HAVING count(*)>1 or prd_id IS NULL;


-- Verificando espaços 

SELECT 
	prd_nm
FROM prata.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);

-- Verificando nulos e números negativos

SELECT prd_cost 
FROM prata.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL;


-- Verificando padronização e consistência

SELECT distinct prd_line 
FROM prata.crm_prd_info;


-- Checando as colunas de datas

SELECT *
FROM prata.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

SELECT 
	prd_id,
	prd_key,
	prd_nm,
	prd_start_dt,
	prd_end_dt,
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');


  -- Ajustando colunas para inserção de dados nas tabelas

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
SELECT prd_id,
	  REPLACE(SUBSTRING(prd_key,1,5),'-', '_') AS cat_id,
	  SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
      prd_nm,
      ISNULL(prd_cost,0) AS prd_cost,
     CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a' 
	END AS prd_line,
      CAST(prd_start_dt AS DATE),
      CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS DATE) AS prd_end_dt
  FROM bronze.crm_prd_info;
