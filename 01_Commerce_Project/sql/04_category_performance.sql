-- Top 10 Product Categories by Sales Value
-- Delivered orders only, excluding shipping fees

SELECT
    p.product_category_name AS category,

    COUNT(*) AS items_sold,

    COUNT(DISTINCT oi.order_id) AS order_count,

    ROUND(SUM(oi.price), 2) AS total_sales,

    ROUND(AVG(oi.price), 2) AS average_item_price

FROM order_items_fe AS oi

INNER JOIN products_fe AS p
    ON oi.product_id = p.product_id

INNER JOIN orders_fe AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'delivered'
    AND p.product_category_name IS NOT NULL

GROUP BY p.product_category_name

ORDER BY total_sales DESC

LIMIT 10;

-- ============================================================
-- 2. CATEGORY SHARE OF TOTAL PRODUCT SALES
-- ============================================================

WITH category_sales AS (
    SELECT
        p.product_category_name AS category,
        SUM(oi.price) AS total_sales

    FROM order_items_fe AS oi

    INNER JOIN products_fe AS p
        ON oi.product_id = p.product_id

    INNER JOIN orders_fe AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'
      AND p.product_category_name IS NOT NULL

    GROUP BY p.product_category_name
)

SELECT
    category,

    ROUND(total_sales, 2) AS total_sales,

    ROUND(
        100.0 * total_sales
        / NULLIF(SUM(total_sales) OVER (), 0),
        2
    ) AS sales_share_pct

FROM category_sales

ORDER BY total_sales DESC

LIMIT 10;