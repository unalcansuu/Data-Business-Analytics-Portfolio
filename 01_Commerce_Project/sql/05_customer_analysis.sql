-- ============================================================
-- 1. CUSTOMER PURCHASE FREQUENCY
-- One-time vs Repeat Customers
-- ============================================================

WITH customer_orders AS (

    SELECT
        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS order_count,

        CASE
            WHEN COUNT(DISTINCT o.order_id) >= 2
                THEN 'Repeat Customer'
            ELSE 'One-time Customer'
        END AS customer_type

    FROM orders_fe AS o

    INNER JOIN customers_fe AS c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.customer_unique_id

)

SELECT
    customer_type,

    COUNT(*) AS customer_count,

    ROUND(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_share_pct,

    ROUND(AVG(order_count), 2) AS avg_orders_per_customer

FROM customer_orders

GROUP BY customer_type

ORDER BY customer_count DESC;