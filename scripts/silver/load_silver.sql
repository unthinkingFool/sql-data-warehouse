

INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gender,
	cst_create_date
)
SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) cst_firstname,
	TRIM(cst_lastname) cst_lastname,
	CASE WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
		 WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
		 ELSE 'n/a' -- normalizing marital status valus to a readable format
	END cst_marital_status,
	CASE WHEN UPPER(TRIM(cst_gender))='F' THEN 'Female'
		 WHEN UPPER(TRIM(cst_gender))='M' THEN 'Male'
		 ELSE 'n/a' -- normalizing gender valus to a readable format
	END cst_gender,
	cst_create_date
FROM
(
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t
WHERE flag=1 -- select the most recent record per customer -> removing duplicates




--=============================================================================
-- =============================================================================

INSERT INTO silver.crm_prd_info
(
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
       prd_id
      ,REPLACE(SUBSTRING(prd_key,1,5),'-','_') cat_id -- extracting new column 
      ,SUBSTRING(prd_key,7,LEN(prd_key)) prd_key -- extracting new column 
      ,prd_nm
      ,ISNULL(prd_cost,0) prd_cost
      ,CASE WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line))='S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
            ELSE 'n/a' -- data normalization
        END prd_line
      ,CAST(prd_start_dt AS DATE) prd_start_dt -- data type casting
      ,CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt asc)-1 AS DATE) prd_end_dt -- data enrichment
  FROM bronze.crm_prd_info
