-- Question 2: Which product categories bring in the most revenue, and which earn the best review scores?
-- Built on the star schema (mart). Revenue = item prices of orders that are not canceled or unavailable.
-- Assumptions:
--   - Canceled and unavailable orders are excluded from both revenue and reviews.
--   - A review belongs to the order: an order with items from two categories counts once in each.
--   - Category averages only include categories with at least 50 reviewed orders.

-- 1. Revenue by category and share of total revenue (top 10).
-- The window SUM(SUM(price)) OVER () runs before LIMIT, so the share is of all revenue.
-- Result: the top 10 of 72 categories bring 62.4% of revenue (8.42M of 13.49M).
SELECT
	dp.product_category_name_english,
	SUM(price) AS category_revenue,
	SUM(SUM(price)) OVER () AS total_revenue,
	ROUND(100.0 * SUM(price) / SUM(SUM(price)) OVER (), 2) AS share_in_pct
FROM
	mart.fact_order_items foi
JOIN mart.dim_product dp 
ON
	foi.product_id = dp.product_id
WHERE
	foi.order_status NOT IN ('canceled', 'unavailable')
GROUP BY
	dp.product_category_name_english
ORDER BY
	category_revenue DESC
LIMIT 10;

-- 2. Average review score by category.
-- Reviews are at order grain, items at item grain: a plain join repeats an order's score once
-- per item (fan-out). The CTE reduces the rows to one per order and category before averaging.
-- Result: best books general interest 4.50; worst office furniture 3.62 (59 categories with 50+ reviews).
WITH order_category_scores AS (
SELECT
	dp.product_category_name_english,
	fo.order_id,
	AVG(fo.review_score) AS score
FROM
	mart.fact_order_items foi
JOIN mart.dim_product dp 
ON
	foi.product_id = dp.product_id
JOIN mart.fact_orders fo
ON
	foi.order_id = fo.order_id
WHERE
	foi.order_status NOT IN ('canceled', 'unavailable')
GROUP BY
	dp.product_category_name_english,
	fo.order_id
)
SELECT
	product_category_name_english,
	ROUND(AVG(score), 2) AS avg_review_score,
	COUNT(order_id) AS reviewed_orders
FROM
	order_category_scores
WHERE
	score IS NOT NULL
GROUP BY
	product_category_name_english
HAVING
	COUNT(order_id) >= 50
ORDER BY
	avg_review_score ASC;

-- 3. Revenue and reviews side by side for the top 10 categories (LEFT JOIN keeps all 10).
-- Result: bed_bath_table (#3, 7.7% of revenue) rates 3.97 and furniture_decor (#6, 5.4%) 4.02,
-- both below the 4.12 average; the best-rated categories are all outside the top 10.
WITH revenue_by_category AS (
SELECT
	dp.product_category_name_english,
	SUM(price) AS category_revenue,
	SUM(SUM(price)) OVER () AS total_revenue,
	ROUND(100.0 * SUM(price) / SUM(SUM(price)) OVER (), 2) AS share_in_pct
FROM
	mart.fact_order_items foi
JOIN mart.dim_product dp 
ON
	foi.product_id = dp.product_id
WHERE
	foi.order_status NOT IN ('canceled', 'unavailable')
GROUP BY
	dp.product_category_name_english
ORDER BY
	category_revenue DESC
LIMIT 10
), 
reviews_by_category AS (
WITH order_category_scores AS (
SELECT
	dp.product_category_name_english,
	fo.order_id,
	AVG(fo.review_score) AS score
FROM
	mart.fact_order_items foi
JOIN mart.dim_product dp 
ON
	foi.product_id = dp.product_id
JOIN mart.fact_orders fo
ON
	foi.order_id = fo.order_id
WHERE
	foi.order_status NOT IN ('canceled', 'unavailable')
GROUP BY
	dp.product_category_name_english,
	fo.order_id
)
SELECT
	product_category_name_english,
	ROUND(AVG(score), 2) AS avg_review_score,
	COUNT(order_id) AS reviewed_orders
FROM
	order_category_scores
WHERE
	score IS NOT NULL
GROUP BY
	product_category_name_english
HAVING
	COUNT(order_id) >= 50
ORDER BY
	avg_review_score DESC
)
SELECT
	rev.product_category_name_english,
	rev.category_revenue,
	rev.share_in_pct,
	rv.avg_review_score,
	rv.reviewed_orders
FROM
	revenue_by_category rev
LEFT JOIN reviews_by_category rv
ON
	rev.product_category_name_english = rv.product_category_name_english
ORDER BY
	rev.category_revenue DESC;
