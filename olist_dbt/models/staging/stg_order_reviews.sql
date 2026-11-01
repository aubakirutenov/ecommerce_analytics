SELECT
    review_id,
    order_id,
    CAST(review_score AS integer) AS review_score
FROM {{ source('olist', 'order_reviews') }}