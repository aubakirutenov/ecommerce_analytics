-- is_late comes from fact_orders: every item of a late order counts as late
-- (an order with several sellers counts as late for each of them).
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    fo.customer_id,
    fo.order_status,
    fo.purchase_date,
    oi.price,
    oi.freight_value,
    fo.is_late
FROM {{ ref('stg_order_items') }} oi
JOIN {{ ref('fact_orders') }} fo
    ON oi.order_id = fo.order_id