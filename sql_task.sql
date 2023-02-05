-- First Query

SELECT product_name, product_img_url, product_url, product_price_min, product_short_description
FROM grommet_products
JOIN grommet_product_categories ON grommet_products.id = grommet_product_categories.product_id
JOIN grommet_gifts_categories ON grommet_product_categories.product_category_id = grommet_gifts_categories.id
WHERE sub_category = "Jewelry" AND is_sold_out = 0;

-- Second Query

SELECT product_name,product_img_url, product_url, product_price_min, product_short_description
FROM grommet_products
JOIN grommet_product_to_keyword ON grommet_products.id = grommet_product_to_keyword.product_id
JOIN grommet_product_keywords ON grommet_product_to_keyword.keyword_id = grommet_product_keywords.id
WHERE keyword = "Hair accessor" AND is_sold_out = 0;

-- Third Query

SELECT product_name, product_img_url, product_url, product_price_min, product_short_description
FROM grommet_products
JOIN (
SELECT product_id
FROM grommet_product_categories
JOIN grommet_gifts_categories ON grommet_product_categories.product_category_id = grommet_gifts_categories.id
WHERE sub_category IN ("Beauty & Personal Care", "Skincare")
UNION
SELECT product_id
FROM grommet_product_to_keyword
JOIN grommet_product_keywords ON grommet_product_to_keyword.keyword_id = grommet_product_keywords.id
WHERE keyword = "Aromatherapy"
) tmp ON grommet_products.id = tmp.product_id
WHERE is_sold_out = 0;
