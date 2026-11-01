SELECT
    product_category_name,
    product_category_name_english
FROM {{ source('olist', 'product_category_translation') }}