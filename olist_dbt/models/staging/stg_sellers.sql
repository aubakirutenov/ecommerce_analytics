SELECT
    seller_id,
    seller_city,
    seller_state
FROM {{ source('olist', 'sellers') }}