WITH reviews AS (
    SELECT
        order_id,
        AVG(review_score) AS review_score
    FROM {{ ref('stg_order_reviews') }}
    GROUP BY order_id
)

SELECT
    o.order_id,
    o.customer_id,
    o.purchased_at::date AS purchase_date,
    o.order_status,
    o.delivered_at::date AS delivered_date,
    o.estimated_at::date AS estimated_date,
    CASE
        WHEN o.order_status = 'delivered' AND o.delivered_at::date >  o.estimated_at::date THEN 1
        WHEN o.order_status = 'delivered' AND o.delivered_at::date <= o.estimated_at::date THEN 0
    END AS is_late,  -- NULL for undelivered orders and delivered orders without a delivery date
    r.review_score
FROM {{ ref('stg_orders') }} o
LEFT JOIN reviews r
    ON o.order_id = r.order_id