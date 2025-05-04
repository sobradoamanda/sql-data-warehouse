-- Buscando valores nulos ou duplicados

select * from bronze.crm_cust_info;

-- Verificando se temos chaves primárias duplicadas
select 
	cst_id,
	count(*)
from bronze.crm_cust_info
group by cst_id
having count(*)>1 or cst_id IS NULL;

select 
	*
from bronze.crm_cust_info
where cst_id = 29449;

-- Rankeando e ordenando as chaves primárias por data de criação
select 
	*,
	row_number() over(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
from bronze.crm_cust_info
;

-- Selcionando apenas as chaves primárias com flag_last = 1, ou seja, os ids com as datas mais atuais
select * 
from 
(select 
	*,
	row_number() over(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
from bronze.crm_cust_info) t
where flag_last = 1;


select * 
from 
(select 
	*,
	row_number() over(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
from bronze.crm_cust_info) t
where flag_last = 1 and cst_id = 29483;

-- Verificando espaços 

select 
	cst_firstname
from bronze.crm_cust_info
where cst_firstname <> TRIM(cst_firstname);

select 
	cst_lastname
from bronze.crm_cust_info
where cst_firstname <> TRIM(cst_lastname);

select 
	cst_lastname
from bronze.crm_cust_info
where cst_firstname <> TRIM(cst_lastname);

select 
	cst_marital_status
from bronze.crm_cust_info
where cst_firstname <> TRIM(cst_marital_status);

select 
	cst_gndr
from bronze.crm_cust_info
where cst_firstname <> TRIM(cst_gndr);


-- Verificando Consistencia e padronização

select 
	distinct(cst_gndr)
from bronze.crm_cust_info;

select 
	distinct(cst_marital_status)
from bronze.crm_cust_info;


-- Ajustando colunas para inserção de dados nas tabelas

insert into prata.crm_cust_info (
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date)

select 
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
	 ELSE 'n/a' 
END AS cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	 ELSE 'n/a' 
END AS cst_gndr,
cst_create_date
from 
(select 
	*,
	row_number() over(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
from bronze.crm_cust_info
where cst_id is not null) as t
where flag_last = 1;

