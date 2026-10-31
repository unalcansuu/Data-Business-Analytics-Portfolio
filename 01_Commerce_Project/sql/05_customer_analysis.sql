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

-- ============================================================
-- 2. TIME TO SECOND PURCHASE
-- ============================================================

WITH ranked_orders AS (

    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,

        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp, o.order_id
        ) AS purchase_rank

    FROM orders_fe AS o

    INNER JOIN customers_fe AS c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'

),

first_second_orders AS (

    SELECT
        customer_unique_id,

        MAX(order_purchase_timestamp) FILTER (
            WHERE purchase_rank = 1
        ) AS first_purchase,

        MAX(order_purchase_timestamp) FILTER (
            WHERE purchase_rank = 2
        ) AS second_purchase

    FROM ranked_orders

    GROUP BY customer_unique_id

),

purchase_intervals AS (

    SELECT
        customer_unique_id,

        EXTRACT(EPOCH FROM (
            second_purchase - first_purchase
        )) / 86400.0 AS days_to_second_purchase

    FROM first_second_orders

    WHERE second_purchase IS NOT NULL

)

SELECT
    COUNT(*) AS repeat_customers,

    ROUND(
        AVG(days_to_second_purchase)::NUMERIC, 2
    ) AS avg_days_to_second_purchase,

    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY days_to_second_purchase
        )::NUMERIC, 2
    ) AS median_days_to_second_purchase,

    COUNT(*) FILTER (
        WHERE days_to_second_purchase <= 30
    ) AS returned_within_30_days,

    COUNT(*) FILTER (
        WHERE days_to_second_purchase <= 90
    ) AS returned_within_90_days

FROM purchase_intervals;

-- ============================================================
-- 3. MONTHLY CUSTOMER COHORT RETENTION
-- ============================================================

WITH delivered_purchases AS (

    SELECT
        c.customer_unique_id,

        DATE_TRUNC(
            'month',
            o.order_purchase_timestamp
        )::DATE AS purchase_month

    FROM orders_fe AS o

    INNER JOIN customers_fe AS c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'

),

first_purchase AS (

    -- Find each customer's first purchase month
    SELECT
        customer_unique_id,
        MIN(purchase_month) AS cohort_month

    FROM delivered_purchases

    GROUP BY customer_unique_id

),

monthly_activity AS (

    -- Count each customer only once per month
    SELECT DISTINCT
        customer_unique_id,
        purchase_month

    FROM delivered_purchases

)

SELECT
    f.cohort_month,

    COUNT(DISTINCT f.customer_unique_id)
        AS cohort_size,

    ROUND(
        100.0 * COUNT(DISTINCT a.customer_unique_id)
            FILTER (
                WHERE a.purchase_month =
                    (f.cohort_month + INTERVAL '1 month')::DATE
            )
        / NULLIF(COUNT(DISTINCT f.customer_unique_id), 0),
        2
    ) AS retention_month_1,

    ROUND(
        100.0 * COUNT(DISTINCT a.customer_unique_id)
            FILTER (
                WHERE a.purchase_month =
                    (f.cohort_month + INTERVAL '2 months')::DATE
            )
        / NULLIF(COUNT(DISTINCT f.customer_unique_id), 0),
        2
    ) AS retention_month_2,

    ROUND(
        100.0 * COUNT(DISTINCT a.customer_unique_id)
            FILTER (
                WHERE a.purchase_month =
                    (f.cohort_month + INTERVAL '3 months')::DATE
            )
        / NULLIF(COUNT(DISTINCT f.customer_unique_id), 0),
        2
    ) AS retention_month_3

FROM first_purchase AS f

LEFT JOIN monthly_activity AS a
    ON f.customer_unique_id = a.customer_unique_id

WHERE f.cohort_month >= '2017-01-01'
  AND f.cohort_month < '2018-05-01'

GROUP BY f.cohort_month

ORDER BY f.cohort_month;