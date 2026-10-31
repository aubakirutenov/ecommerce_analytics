-- UNION and UNION ALL
--1. One list of all states where Olist has a customer or a seller, each state once.
SELECT
	seller_state AS state
FROM
	olist.sellers s
UNION
SELECT
	customer_state
FROM
	olist.customers c
ORDER BY
	state ASC;

--2. The same query with UNION ALL.
SELECT
	seller_state AS state
FROM
	olist.sellers s
UNION ALL
SELECT
	customer_state
FROM
	olist.customers c
ORDER BY
	state ASC;

--3. One result with three columns, role (‘customer’ or ‘seller’), state and count, so customers and sellers per state are stacked in one table. 
-- Sort by state, then role.
SELECT
	'seller' AS ROLE,
	seller_state AS state,
	COUNT(seller_id) AS count
FROM
	olist.sellers
GROUP BY
	state
UNION ALL
SELECT
	'customer' AS ROLE,
	customer_state AS state,
	COUNT(DISTINCT customer_unique_id) AS count
FROM
	olist.customers
GROUP BY
	state
ORDER BY
	state,
	ROLE ASC;

-- String functions
--4. Show product_category_name_english in readable form: “health_beauty” becomes “Health Beauty”.
SELECT
	INITCAP(REPLACE(product_category_name_english, '_', ' ')) AS category_name
FROM
	olist.product_category_translation pct;

--5. Check the type of customer_zip_code_prefix with pg_typeof. If it’s a number, leading zeros are lost. 
-- Show it as 5-character text with the zeros back.
SELECT
	COUNT(*) FILTER(WHERE LPAD(customer_zip_code_prefix::TEXT, 5, '0') LIKE '0%') AS zero_index_count
FROM
	olist.customers c;

--6. In geolocation, find every spelling of São Paulo in state SP: with and without the accent, in any letter case. 
-- How many different spellings are there, and what does that mean for joining tables on city names?
SELECT
	geolocation_city AS city_spelling,
	COUNT(geolocation_city) AS counts
FROM
	olist.geolocation
WHERE
	geolocation_state = 'SP'
	AND geolocation_city ILIKE 's%paulo%'
GROUP BY
	geolocation_city
ORDER BY
	counts DESC;
-- 4 spellings of São Paulo in SP (sao paulo 135,799; são paulo 24,917; sãopaulo 2; sa£o paulo 1).
-- Grouping on city names splits one city into several groups, and joins on names silently drop
-- non-matching rows. Join on zip prefix instead, or normalize names (LOWER, TRIM, unaccent).

-- EXPLAIN
--7. Write a query: total revenue for one seller (pick any seller_id) from order_items. 
-- Put EXPLAIN in front. What scan type does the plan use, and how many rows does it estimate?
EXPLAIN
SELECT
	seller_id,
	SUM(price) AS total_revenue
FROM
	olist.order_items
WHERE
	seller_id = '48436dade18ac8b2bce089ec2a041202'
GROUP BY
	seller_id;
-- Seq Scan: PostgreSQL reads all 112,650 rows of order_items and checks each one
-- against the filter. It estimates 26 matching rows. There is no index on seller_id,
-- so reading the whole table is the only option.

--8. Run the same query with EXPLAIN ANALYZE. Compare the estimated rows and the actual rows, and note the execution time.
EXPLAIN ANALYZE
SELECT
	seller_id,
	SUM(price) AS total_revenue
FROM
	olist.order_items
WHERE
	seller_id = '48436dade18ac8b2bce089ec2a041202'
GROUP BY
	seller_id;
-- EXPLAIN ANALYZE really runs the query: 151 rows match (112,650 - 112,499 removed
-- by the filter), so the estimate of 26 was about 6x too low. Execution time 21.7 ms;
-- 2,432 blocks of 8 KB read, all from memory.

--9. Create an index on order_items(seller_id) and run EXPLAIN ANALYZE again. What changed in the scan type and the time? 
-- Keep the CREATE INDEX statement apart from the analysis queries, so re-running the file doesn’t try to create it twice.
CREATE INDEX IF NOT EXISTS idx_order_items_seller_id ON olist.order_items (seller_id);
   SELECT indexname FROM pg_indexes WHERE tablename = 'order_items';

EXPLAIN ANALYZE
SELECT
	seller_id,
	SUM(price) AS total_revenue
FROM
	olist.order_items
WHERE
	seller_id = '48436dade18ac8b2bce089ec2a041202'
GROUP BY
	seller_id;
-- With an index on seller_id: Bitmap Index Scan finds the seller's rows in the index,
-- then Bitmap Heap Scan reads only the 135 blocks that contain them (138 blocks in total
-- instead of 2,432). Execution time 3.2 ms instead of 21.7 ms.
-- Indexes speed up filters and joins on a column, but take space and slow down writes.