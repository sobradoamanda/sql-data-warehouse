SELECT
	id,
    cat,
    subcat,
    maintenance
  FROM bronze.erp_px_cat_g1v2;

SELECT cat_id FROM prata.crm_prd_info

-- Checando espaços indesejados
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat!= TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Checando padronização
SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2

-- Ajustando colunas
INSERT INTO prata.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
SELECT
	id,
    cat,
    subcat,
    maintenance
  FROM bronze.erp_px_cat_g1v2;



  SELECT * FROM prata.erp_px_cat_g1v2