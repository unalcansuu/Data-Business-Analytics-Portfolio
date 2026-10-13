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

-- ============================================================
-- 3. YEAR-OVER-YEAR CATEGORY SALES GROWTH
-- January - August | 2017 vs 2018
-- ============================================================

WITH category_year_sales AS (

    -- Step 1: Calculate sales by category and year
    SELECT
        p.product_category_name AS category,

        EXTRACT(YEAR FROM o.order_purchase_timestamp)::INTEGER
            AS sales_year,

        SUM(oi.price) AS total_sales

    FROM order_items_fe AS oi

    INNER JOIN products_fe AS p
        ON oi.product_id = p.product_id

    INNER JOIN orders_fe AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'
      AND p.product_category_name IS NOT NULL

      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'

      AND EXTRACT(MONTH FROM o.order_purchase_timestamp)
          BETWEEN 1 AND 8

    GROUP BY
        p.product_category_name,
        EXTRACT(YEAR FROM o.order_purchase_timestamp)

),

sales_comparison AS (

    -- Step 2: Get previous year's sales
    SELECT
        category,
        sales_year,
        total_sales,

        LAG(sales_year) OVER (
            PARTITION BY category
            ORDER BY sales_year
        ) AS previous_year,

        LAG(total_sales) OVER (
            PARTITION BY category
            ORDER BY sales_year
        ) AS previous_year_sales

    FROM category_year_sales

)

-- Step 3: Calculate year-over-year growth
SELECT
    category,

    ROUND(previous_year_sales, 2) AS sales_2017,

    ROUND(total_sales, 2) AS sales_2018,

    ROUND(
        total_sales - previous_year_sales, 2
    ) AS sales_growth_amount,

    ROUND(
        100.0 * (total_sales - previous_year_sales)
        / NULLIF(previous_year_sales, 0),
        2
    ) AS sales_growth_pct

FROM sales_comparison

WHERE sales_year = 2018
  AND previous_year = 2017

ORDER BY sales_growth_pct DESC NULLS LAST

LIMIT 10;

-- ============================================================
-- 4. CATEGORY SALES DISTRIBUTION IN 2017 (JAN - AUG)
-- ============================================================

WITH category_sales_2017 AS (

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
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2017-09-01'

    GROUP BY p.product_category_name
)

SELECT
    COUNT(*) AS category_count,

    ROUND(MIN(total_sales), 2) AS min_sales,

    ROUND(
        PERCENTILE_CONT(0.25) WITHIN GROUP (
            ORDER BY total_sales
        )::NUMERIC, 2
    ) AS p25_sales,

    ROUND(
        PERCENTILE_CONT(0.50) WITHIN GROUP (
            ORDER BY total_sales
        )::NUMERIC, 2
    ) AS median_sales,

    ROUND(
        PERCENTILE_CONT(0.75) WITHIN GROUP (
            ORDER BY total_sales
        )::NUMERIC, 2
    ) AS p75_sales,

    ROUND(MAX(total_sales), 2) AS max_sales

FROM category_sales_2017;

-- ============================================================
-- 5. CATEGORY GROWTH WITH BASELINE SALES THRESHOLD
-- January - August | 2017 vs 2018
-- ============================================================

WITH category_year_sales AS (

    -- Calculate product sales by category and year
    SELECT
        p.product_category_name AS category,

        EXTRACT(YEAR FROM o.order_purchase_timestamp)::INTEGER
            AS sales_year,

        SUM(oi.price) AS total_sales

    FROM order_items_fe AS oi

    INNER JOIN products_fe AS p
        ON oi.product_id = p.product_id

    INNER JOIN orders_fe AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'
      AND p.product_category_name IS NOT NULL
      AND o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
      AND EXTRACT(MONTH FROM o.order_purchase_timestamp)
          BETWEEN 1 AND 8

    GROUP BY
        p.product_category_name,
        EXTRACT(YEAR FROM o.order_purchase_timestamp)

),

sales_comparison AS (

    -- Compare each category with its previous year
    SELECT
        category,
        sales_year,
        total_sales,

        LAG(sales_year) OVER (
            PARTITION BY category
            ORDER BY sales_year
        ) AS previous_year,

        LAG(total_sales) OVER (
            PARTITION BY category
            ORDER BY sales_year
        ) AS previous_year_sales

    FROM category_year_sales

)

SELECT
    category,

    ROUND(previous_year_sales, 2) AS sales_2017,

    ROUND(total_sales, 2) AS sales_2018,

    ROUND(
        total_sales - previous_year_sales, 2
    ) AS sales_growth_amount,

    ROUND(
        100.0 * (total_sales - previous_year_sales)
        / NULLIF(previous_year_sales, 0),
        2
    ) AS sales_growth_pct

FROM sales_comparison

WHERE sales_year = 2018
  AND previous_year = 2017
  AND previous_year_sales >= 7717.34

ORDER BY sales_growth_pct DESC

LIMIT 10;