
/* ASSIGNMENT 2 */
/* SECTION 2 */

-- COALESCE
/* 1. Create a formatted product list handling NULLs with COALESCE */
SELECT 
  product_name || ', ' || 
  COALESCE(product_size, '') || ' (' || 
  COALESCE(product_qty_type, 'unit') || ')'
AS formatted_product
FROM product;

-- WINDOWED FUNCTIONS
/* 2. Number each customer's visits to the market */
SELECT 
  customer_id,
  market_date,
  ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY market_date) AS visit_number
FROM customer_purchases;

/* 3. Reverse the numbering for most recent visit = 1, and show only the most recent visit */
WITH visits AS (
  SELECT 
    customer_id,
    market_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY market_date DESC) AS rev_visit
  FROM customer_purchases
)
SELECT *
FROM visits
WHERE rev_visit = 1;

-- COUNT() WINDOW FUNCTION
/* 4. Count how many different times each customer bought a product */
SELECT 
  customer_id,
  product_id,
  purchase_date,
  COUNT(*) OVER (PARTITION BY customer_id, product_id) AS product_purchase_count
FROM customer_purchases;

-- STRING MANIPULATION
/* 5. Extract product descriptions from product_name using INSTR and SUBSTR */
SELECT 
  product_name,
  TRIM(SUBSTR(product_name, INSTR(product_name, '-') + 1)) AS description
FROM product
WHERE INSTR(product_name, '-') > 0;

-- UNION - BEST AND WORST MARKET DAYS
/* 6. Show market dates with highest and lowest total sales */
WITH sales_per_day AS (
  SELECT market_date, SUM(price_paid) AS total_sales
  FROM customer_purchases
  GROUP BY market_date
),
ranked_sales AS (
  SELECT *,
         RANK() OVER (ORDER BY total_sales DESC) AS rank_high,
         RANK() OVER (ORDER BY total_sales ASC) AS rank_low
  FROM sales_per_day
)
SELECT market_date, total_sales, 'Highest' AS sales_rank
FROM ranked_sales
WHERE rank_high = 1
UNION
SELECT market_date, total_sales, 'Lowest' AS sales_rank
FROM ranked_sales
WHERE rank_low = 1;

-- CROSS JOIN
/* 7. Each vendor has 5 of each product for each customer — calculate potential revenue */
SELECT 
  v.vendor_name,
  p.product_name,
  COUNT(DISTINCT c.customer_id) * 5 * vi.price AS potential_revenue
FROM vendor_inventory vi
JOIN vendor v ON vi.vendor_id = v.vendor_id
JOIN product p ON vi.product_id = p.product_id
CROSS JOIN customer c
GROUP BY v.vendor_name, p.product_name, vi.price;

-- INSERT
/* 8. Create new table product_units with timestamp column and insert a new row */
CREATE TABLE IF NOT EXISTS product_units AS
SELECT *, CURRENT_TIMESTAMP AS snapshot_timestamp
FROM product
WHERE product_qty_type = 'unit';

INSERT INTO product_units
SELECT *, CURRENT_TIMESTAMP
FROM product
WHERE product_name = 'Apple Pie';

-- DELETE
/* 9. Delete older duplicate record of newly inserted product */
DELETE FROM product_units
WHERE rowid NOT IN (
  SELECT MAX(rowid)
  FROM product_units
  WHERE product_name = 'Apple Pie'
);

-- UPDATE
/* 10. Add current_quantity column and update with latest vendor_inventory quantity */
ALTER TABLE product_units
ADD COLUMN current_quantity INT;

UPDATE product_units
SET current_quantity = (
  SELECT COALESCE(quantity, 0)
  FROM vendor_inventory
  WHERE vendor_inventory.product_id = product_units.product_id
  ORDER BY last_updated DESC
  LIMIT 1
)
WHERE product_id IN (
  SELECT DISTINCT product_id FROM vendor_inventory
);

/* SECTION 3 */

-- INSERT: Add another Apple Pie record into product_units
INSERT INTO product_units
SELECT *, CURRENT_TIMESTAMP
FROM product
WHERE product_name = 'Apple Pie';

-- DELETE: Remove older Apple Pie record(s)
DELETE FROM product_units
WHERE rowid NOT IN (
  SELECT MAX(rowid)
  FROM product_units
  WHERE product_name = 'Apple Pie'
);

-- UPDATE: Add and set current_quantity from vendor_inventory
ALTER TABLE product_units
ADD COLUMN current_quantity INT;

UPDATE product_units
SET current_quantity = (
  SELECT COALESCE(quantity, 0)
  FROM vendor_inventory
  WHERE vendor_inventory.product_id = product_units.product_id
  ORDER BY last_updated DESC
  LIMIT 1
)
WHERE product_id IN (
  SELECT DISTINCT product_id FROM vendor_inventory
);
