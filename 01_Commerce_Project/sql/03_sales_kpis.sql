-- Monthly Sales Performance
-- Product value excludes shipping fees.
-- Only delivered orders are included.

WITH order_totals AS (
    SELECT
        order_id,
        SUM(price) AS product_value,
        SUM(freight_value) AS freight_value,
        COUNT(*) AS item_count
    FROM order_items_fe
    GROUP BY order_id
)

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::DATE
        AS order_month,

    COUNT(*) AS total_orders,

    ROUND(SUM(ot.product_value), 2)
        AS product_sales_value,

    ROUND(
        SUM(ot.product_value) / NULLIF(COUNT(*), 0),
        2
    ) AS average_order_value,

    SUM(ot.item_count) AS total_items_sold

FROM orders_fe o

INNER JOIN order_totals ot
    ON o.order_id = ot.order_id

WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp IS NOT NULL

GROUP BY 1
ORDER BY 1;

-- Diagnose missing monetary values in order items

SELECT
    COUNT(*) AS total_rows,

    COUNT(price) AS non_null_price_rows,

    COUNT(*) FILTER (WHERE price IS NULL)
        AS null_price_rows,

    COUNT(freight_value) AS non_null_freight_rows,

    MIN(price) AS min_price,

    MAX(price) AS max_price,

    SUM(price) AS total_product_value

FROM order_items_fe;

-- ============================================================
-- 2. YEAR-OVER-YEAR SALES GROWTH (JANUARY - AUGUST)
-- ============================================================

WITH order_totals AS (
    SELECT
        order_id,
        SUM(price) AS product_value
    FROM order_items_fe
    GROUP BY order_id
),

yearly_performance AS (
    SELECT
        EXTRACT(YEAR FROM o.order_purchase_timestamp)::INTEGER
            AS sales_year,

        COUNT(*) AS total_orders,

        SUM(ot.product_value) AS product_sales_value,

        ROUND(
            AVG(ot.product_value), 2
        ) AS average_order_value

    FROM orders_fe o

    INNER JOIN order_totals ot
        ON o.order_id = ot.order_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
      AND EXTRACT(MONTH FROM o.order_purchase_timestamp)
          BETWEEN 1 AND 8

    GROUP BY 1
)

SELECT
    a.total_orders AS orders_2017,
    b.total_orders AS orders_2018,

    ROUND(
        100.0 * (b.total_orders - a.total_orders)
        / NULLIF(a.total_orders, 0), 2
    ) AS order_growth_pct,

    ROUND(a.product_sales_value, 2) AS sales_2017,
    ROUND(b.product_sales_value, 2) AS sales_2018,

    ROUND(
        100.0 * (b.product_sales_value - a.product_sales_value)
        / NULLIF(a.product_sales_value, 0), 2
    ) AS sales_growth_pct,

    a.average_order_value AS aov_2017,
    b.average_order_value AS aov_2018,

    ROUND(
        100.0 * (b.average_order_value - a.average_order_value)
        / NULLIF(a.average_order_value, 0), 2
    ) AS aov_growth_pct

FROM yearly_performance a

INNER JOIN yearly_performance b
    ON a.sales_year = 2017
   AND b.sales_year = 2018;