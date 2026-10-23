# Naming Conventions

## Purpose
This document defines naming standards for the SQL Server data warehouse. Consistent names make the Bronze, Silver, and Gold layers easier to navigate, maintain, and use in analytics.

## General Rules
- Use `snake_case` (lowercase words separated by underscores).
- Use descriptive English names; avoid spaces, special characters, and SQL reserved words.
- Keep names consistent across related objects.
- Use singular business entities for dimension and fact view names as established in this project (`dim_customers`, `dim_products`, `fact_sales` are the existing exceptions to strict singular wording).
- Name columns for their business meaning rather than their original source-system abbreviation in the Gold layer.
- Do not rename existing source fields solely to satisfy these conventions unless the transformation requires it.

## 1. Database and Schemas

| Object | Convention | Example |
|---|---|---|
| Database | Descriptive `snake_case` name | `data_warehouse` |
| Bronze schema | `bronze` | `bronze.crm_cust_info` |
| Silver schema | `silver` | `silver.crm_cust_info` |
| Gold schema | `gold` | `gold.dim_customers` |

## 2. Bronze Layer — Source-Aligned Tables

**Pattern:** `<source_system>_<source_entity>`

Retain recognizable source-system and entity names so raw data is traceable.

| Example | Meaning |
|---|---|
| `bronze.crm_cust_info` | CRM customer information |
| `bronze.crm_prd_info` | CRM product information |
| `bronze.crm_sales_details` | CRM sales details |
| `bronze.erp_cust_az12` | ERP customer details |
| `bronze.erp_loc_a101` | ERP location details |
| `bronze.erp_px_cat_g1v2` | ERP product categories |

## 3. Silver Layer — Cleaned Tables

**Pattern:** `<source_system>_<source_entity>`

Preserve Bronze table names in the Silver schema for straightforward lineage. Clean and standardize values here without losing source traceability.

Examples: `silver.crm_cust_info`, `silver.erp_cust_az12`, `silver.crm_sales_details`.

## 4. Gold Layer — Business-Ready Views

**Pattern:** `<object_type>_<business_entity>`

| Prefix | Usage | Existing View |
|---|---|---|
| `dim_` | Descriptive dimension | `gold.dim_customers` |
| `fact_` | Measurable business events | `gold.fact_sales` |

Current Gold views:
- `gold.dim_customers` — customer attributes
- `gold.dim_products` — current product attributes
- `gold.fact_sales` — sales-detail transactions

## 5. Gold Column Names

| Convention | Purpose | Examples |
|---|---|---|
| `<entity>_key` | Warehouse-generated surrogate or dimension reference key | `customer_key`, `product_key` |
| `<entity>_id` | Source-system identifier | `customer_id`, `product_id` |
| `<entity>_number` | Business-facing identifier | `customer_number`, `product_number`, `order_number` |
| `*_date` | Calendar date | `order_date`, `shipping_date`, `due_date`, `create_date`, `start_date` |
| Descriptive measures | Numeric business values | `sales_amount`, `quantity`, `price`, `product_cost` |
| Descriptive attributes | Human-readable categories or properties | `first_name`, `last_name`, `country`, `subcategory` |

**Current-schema exception:** `gold.dim_products.prd_end_dt` retains its source name. For future consistency, consider aliasing it to `end_date` when updating the view and any dependent queries.

**Date naming note:** `birthdate` is retained as used in the existing view. Avoid changing public Gold column names without reviewing downstream dependencies.

## 6. Keys and Relationships

- Use `customer_key` as the logical primary key of `gold.dim_customers`.
- Use `product_key` as the logical primary key of `gold.dim_products`.
- Reuse these exact names in `gold.fact_sales` for the corresponding logical foreign keys.
- Keep source identifiers (`customer_id`, `product_id`) distinct from warehouse surrogate keys (`customer_key`, `product_key`).
- `order_number` is a business identifier, not necessarily a unique fact-row key.
- Views express logical relationships; ordinary SQL Server views do not enforce primary-key or foreign-key constraints.

## 7. SQL Script Filenames

**Recommended pattern:** `<layer>_<action>_<object>.sql`

| Purpose | Suggested Filename |
|---|---|
| Create database and schemas | `init_database.sql` |
| Load Bronze CRM tables | `bronze_load_crm.sql` |
| Load Silver tables | `silver_load.sql` |
| Create Gold customer view | `gold_dim_customers.sql` |
| Create Gold product view | `gold_dim_products.sql` |
| Create Gold sales view | `gold_fact_sales.sql` |

Choose one convention and use it throughout the repository. Script names are recommendations, not a claim about current filenames.

## 8. Documentation Filenames

Use lowercase `snake_case` Markdown filenames.

| Document | Filename |
|---|---|
| Main repository overview | `README.md` |
| Gold data dictionary | `docs/gold_layer_data_dictionary.md` |
| Naming conventions | `docs/naming_conventions.md` |
| Data architecture | `docs/data_architecture.md` |

## 9. SQL Formatting

- Write SQL keywords in uppercase: `CREATE VIEW`, `SELECT`, `FROM`, `LEFT JOIN`, `WHERE`.
- Use explicit aliases for transformed Gold columns with `AS`.
- Qualify objects with schema names, e.g. `silver.crm_sales_details`.
- Use short, meaningful table aliases such as `ci` (customer information), `pr` (product dimension), and `sd` (sales details).
- Indent selected columns and join conditions consistently.
- End SQL statements with a semicolon.

## 10. Example

```sql
CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_sales AS sales_amount
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cu
    ON sd.sls_cust_id = cu.customer_id;
```

This is a naming and formatting example, not a replacement for the complete project view.
