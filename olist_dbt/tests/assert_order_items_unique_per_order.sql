-- Fails if any order has the same item number twice.
-- The grain of stg_order_items is order_id + order_item_id.
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS n
FROM {{ ref('stg_order_items') }}
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1