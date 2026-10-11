-- Validate row counts after data loading

SELECT 'customers_fe' AS table_name, COUNT(*) AS row_count FROM customers_fe
UNION ALL
SELECT 'orders_fe', COUNT(*) FROM orders_fe
UNION ALL
SELECT 'products_fe', COUNT(*) FROM products_fe
UNION ALL
SELECT 'sellers_fe', COUNT(*) FROM sellers_fe
UNION ALL
SELECT 'order_items_fe', COUNT(*) FROM order_items_fe
UNION ALL
SELECT 'order_payments_fe', COUNT(*) FROM order_payments_fe
UNION ALL
SELECT 'order_reviews_fe', COUNT(*) FROM order_reviews_fe
UNION ALL
SELECT 'marketing_leads_fe', COUNT(*) FROM marketing_leads_fe
UNION ALL
SELECT 'closed_deals_fe', COUNT(*) FROM closed_deals_fe
ORDER BY table_name;

-- Check unmatched records across related tables

SELECT
    'orders → customers' AS relationship,
    COUNT(*) AS unmatched_rows
FROM orders_fe o
LEFT JOIN customers_fe c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT
    'order_items → orders',
    COUNT(*)
FROM order_items_fe oi
LEFT JOIN orders_fe o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'order_items → products',
    COUNT(*)
FROM order_items_fe oi
LEFT JOIN products_fe p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT
    'order_items → sellers',
    COUNT(*)
FROM order_items_fe oi
LEFT JOIN sellers_fe s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL

UNION ALL

SELECT
    'order_payments → orders',
    COUNT(*)
FROM order_payments_fe op
LEFT JOIN orders_fe o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'order_reviews → orders',
    COUNT(*)
FROM order_reviews_fe r
LEFT JOIN orders_fe o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'closed_deals → marketing_leads',
    COUNT(*)
FROM closed_deals_fe cd
LEFT JOIN marketing_leads_fe ml
    ON cd.mql_id = ml.mql_id
WHERE ml.mql_id IS NULL

UNION ALL

SELECT
    'closed_deals → sellers',
    COUNT(*)
FROM closed_deals_fe cd
LEFT JOIN sellers_fe s
    ON cd.seller_id = s.seller_id
WHERE s.seller_id IS NULL;