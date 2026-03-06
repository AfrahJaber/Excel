--------------------------------------------------------------------------------
-- 1. DATABASE SETUP & INITIAL PREVIEW
--------------------------------------------------------------------------------

-- Select the active database
USE EXProject;
GO

-- Preview all records
SELECT * FROM RetailSales;

-- Retrieve the top 10 most recent sales
SELECT TOP 10 *
FROM RetailSales
ORDER BY sale_date DESC;

-- Count total number of records in the table
SELECT COUNT(*) AS total_records 
FROM RetailSales;


--------------------------------------------------------------------------------
-- 2. DATA CLEANING (Handling Missing Values & Formatting)
--------------------------------------------------------------------------------

-- Audit: Identify rows with NULL values across all columns
SELECT *
FROM RetailSales
WHERE 
    transactions_id IS NULL OR 
    sale_date       IS NULL OR 
    sale_time       IS NULL OR 
    customer_id     IS NULL OR 
    gender          IS NULL OR 
    age             IS NULL OR 
    category        IS NULL OR 
    quantiy         IS NULL OR 
    price_per_unit  IS NULL OR 
    cogs            IS NULL OR 
    total_sale      IS NULL;

-- Action: Remove rows with NULL values to ensure data integrity
DELETE FROM RetailSales
WHERE 
    transactions_id IS NULL OR 
    sale_date       IS NULL OR 
    sale_time       IS NULL OR 
    customer_id     IS NULL OR 
    gender          IS NULL OR 
    age             IS NULL OR 
    category        IS NULL OR 
    quantiy         IS NULL OR 
    price_per_unit  IS NULL OR 
    cogs            IS NULL OR 
    total_sale      IS NULL;

-- Data Transformation: Adjust financial columns to 2 decimal places (DECIMAL)
ALTER TABLE RetailSales ALTER COLUMN price_per_unit DECIMAL(10, 2);
ALTER TABLE RetailSales ALTER COLUMN cogs DECIMAL(10, 2);
ALTER TABLE RetailSales ALTER COLUMN total_sale DECIMAL(10, 2);

-- Verify formatted financial columns
SELECT TOP 10 
    transactions_id, 
    price_per_unit, 
    cogs, 
    total_sale
FROM RetailSales;


--------------------------------------------------------------------------------
-- 3. DATA EXPLORATION (Key Metrics)
--------------------------------------------------------------------------------

-- Total sales transactions count
SELECT COUNT(*) AS total_sales_count 
FROM RetailSales;

-- Total unique customers count
SELECT COUNT(DISTINCT customer_id) AS unique_customers_count 
FROM RetailSales;

-- List of unique product categories
SELECT DISTINCT category 
FROM RetailSales;


--------------------------------------------------------------------------------
-- 4. DATA ANALYSIS & BUSINESS KEY PROBLEMS
--------------------------------------------------------------------------------

-- Q1: Total Sales and Orders per Category
SELECT 
    category, 
    SUM(total_sale) AS net_sales,
    COUNT(*) AS total_orders
FROM RetailSales
GROUP BY category
ORDER BY net_sales DESC;

-- Q2: Sales Performance by Time Shift (Morning, Afternoon, Evening)
SELECT 
    CASE 
        WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS total_orders
FROM RetailSales
GROUP BY 
    CASE 
        WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END;

-- Q3: Monthly Revenue Analysis for the Year 2022
SELECT 
    MONTH(sale_date) AS sale_month,
    SUM(total_sale) AS total_revenue
FROM RetailSales
WHERE YEAR(sale_date) = 2022
GROUP BY MONTH(sale_date)
ORDER BY total_revenue DESC;

-- Q4: Demographic Insights: Average Age for 'Beauty' Category
SELECT 
    AVG(age) AS average_age
FROM RetailSales
WHERE category = 'Beauty';

-- Q5: Customer Loyalty: Identify Customers with Multiple Purchases
SELECT 
    customer_id, 
    COUNT(transactions_id) AS total_orders,
    SUM(total_sale) AS total_spent
FROM RetailSales
GROUP BY customer_id
HAVING COUNT(transactions_id) > 1
ORDER BY total_orders DESC;

-- Q6: Gender Preference Analysis per Category
SELECT 
    gender, 
    category, 
    COUNT(transactions_id) AS total_transactions
FROM RetailSales
GROUP BY gender, category
ORDER BY gender, total_transactions DESC;

-- Q7: Final Financial Report (Sales, Cost, Profit, and Margin)
SELECT 
    category, 
    COUNT(transactions_id) AS total_orders,
    SUM(total_sale) AS gross_sales,
    SUM(cogs) AS total_cost,
    SUM(total_sale) - SUM(cogs) AS net_profit,
    ROUND(((SUM(total_sale) - SUM(cogs)) / SUM(total_sale)) * 100, 2) AS profit_margin_pct
FROM RetailSales
GROUP BY category
ORDER BY net_profit DESC;