-- ============================================================
-- 1. TOP 10 SELLERS BY PRODUCT SALES
-- ============================================================

WITH seller_sales AS (

    SELECT
        s.seller_id,
        s.seller_state,
        s.seller_region,

        COUNT(DISTINCT oi.order_id) AS order_count,

        COUNT(*) AS items_sold,

        SUM(oi.price) AS total_sales

    FROM order_items_fe AS oi

    INNER JOIN orders_fe AS o
        ON oi.order_id = o.order_id

    INNER JOIN sellers_fe AS s
        ON oi.seller_id = s.seller_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        s.seller_id,
        s.seller_state,
        s.seller_region

)

SELECT
    seller_id,
    seller_state,
    seller_region,

    order_count,
    items_sold,

    ROUND(total_sales, 2) AS total_sales,

    ROUND(
        total_sales / NULLIF(order_count, 0),
        2
    ) AS avg_sales_per_order,

    ROUND(
        100.0 * total_sales
        / SUM(total_sales) OVER (),
        2
    ) AS sales_share_pct,

    RANK() OVER (
        ORDER BY total_sales DESC
    ) AS sales_rank

FROM seller_sales

ORDER BY total_sales DESC

LIMIT 10;

-- ============================================================
-- 2. SELLER PERFORMANCE DECILES
-- ============================================================

WITH seller_sales AS (

    SELECT
        oi.seller_id,
        SUM(oi.price) AS total_sales

    FROM order_items_fe AS oi

    INNER JOIN orders_fe AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY oi.seller_id

),

seller_groups AS (

    SELECT
        seller_id,
        total_sales,

        NTILE(10) OVER (
            ORDER BY total_sales DESC, seller_id
        ) AS performance_group

    FROM seller_sales

)

SELECT
    performance_group,

    COUNT(*) AS seller_count,

    ROUND(SUM(total_sales), 2) AS group_sales,

    ROUND(
        100.0 * SUM(total_sales)
        / SUM(SUM(total_sales)) OVER (),
        2
    ) AS sales_share_pct

FROM seller_groups

GROUP BY performance_group

ORDER BY performance_group;

-- ============================================================
-- 3. SELLER PERFORMANCE BY STATE
-- ============================================================
-- Business question:
-- Is higher state-level sales performance driven by
-- more active sellers or higher sales per seller?
--
-- Scope: Delivered orders only.
-- Sales exclude freight charges.
-- ============================================================

WITH seller_sales AS (

    SELECT
        s.seller_id,
        s.seller_state,
        s.seller_region,

        SUM(oi.price) AS total_sales

    FROM sellers_fe AS s

    INNER JOIN order_items_fe AS oi
        ON s.seller_id = oi.seller_id

    INNER JOIN orders_fe AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        s.seller_id,
        s.seller_state,
        s.seller_region

),

state_performance AS (

    SELECT
        seller_state,
        seller_region,

        COUNT(*) AS active_sellers,

        SUM(total_sales) AS state_total_sales,

        AVG(total_sales) AS avg_sales_per_seller,

        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY total_sales
        ) AS median_sales_per_seller

    FROM seller_sales

    GROUP BY
        seller_state,
        seller_region

)

SELECT
    seller_state,
    seller_region,

    active_sellers,

    ROUND(state_total_sales, 2)
        AS state_total_sales,

    ROUND(avg_sales_per_seller, 2)
        AS avg_sales_per_seller,

    ROUND(median_sales_per_seller::NUMERIC, 2)
        AS median_sales_per_seller,

    ROUND(
        100.0 * state_total_sales
        / SUM(state_total_sales) OVER (),
        2
    ) AS state_sales_share_pct

FROM state_performance

ORDER BY state_total_sales DESC;