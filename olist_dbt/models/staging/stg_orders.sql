SELECT 
    order_id, 
    customer_id, 
    order_status,
    order_purchase_timestamp AS purchased_at,
    order_delivered_customer_date AS delivered_at,
    order_estimated_delivery_date AS estimated_at
FROM {{ source('olist', 'orders') }}
