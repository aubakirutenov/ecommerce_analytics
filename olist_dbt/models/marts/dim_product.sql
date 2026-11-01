-- 'unknown' covers products with no category and categories missing from the
-- translation table (13 products, see the warning in the staging tests).
SELECT
    p.product_id,
    p.product_category_name,
    COALESCE(t.product_category_name_english, 'unknown') AS product_category_name_english
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_product_category_translation') }} t
    ON p.product_category_name = t.product_category_name