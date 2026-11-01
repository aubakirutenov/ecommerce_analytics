SELECT
    order_id,
    customer_id,
    order_status,
    CAST(order_purchase_timestamp AS timestamp) AS purchased_at,
    CAST(order_delivered_customer_date AS timestamp) AS delivered_at,
    CAST(order_estimated_delivery_date AS timestamp) AS estimated_at
FROM {{ source('olist', 'orders') }}