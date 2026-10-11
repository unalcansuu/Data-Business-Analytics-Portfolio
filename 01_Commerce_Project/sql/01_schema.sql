-- ============================================================
-- OLIST E-COMMERCE ANALYTICS
-- PostgreSQL Database Schema
-- ============================================================

-- Create relational tables for the feature-engineered datasets.
-- Monetary values use NUMERIC.
-- Derived continuous metrics use DOUBLE PRECISION.
-- Primary keys were validated against the source CSV files.
-- Foreign keys will be considered after relationship validation.

BEGIN;


-- ============================================================
-- 1. CUSTOMERS
-- Grain: One row per customer_id
-- ============================================================

CREATE TABLE customers_fe (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT NOT NULL,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT,
    is_repeat_customer BOOLEAN,
    customer_region TEXT
);


-- ============================================================
-- 2. ORDERS
-- Grain: One row per order_id
-- ============================================================

CREATE TABLE orders_fe (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT NOT NULL,
    order_status TEXT,

    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,

    purchase_year INTEGER,
    purchase_month INTEGER,
    purchase_day INTEGER,
    purchase_hour INTEGER,
    purchase_weekday TEXT,

    is_weekend BOOLEAN,

    approval_time_hours DOUBLE PRECISION,
    shipping_time_days DOUBLE PRECISION,
    delivery_time_days DOUBLE PRECISION,
    estimated_delivery_gap_days DOUBLE PRECISION,

    is_late_delivery BOOLEAN,
    purchase_period TEXT
);


-- ============================================================
-- 3. PRODUCTS
-- Grain: One row per product_id
-- ============================================================

CREATE TABLE products_fe (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,

    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,

    product_weight_g DOUBLE PRECISION,
    product_length_cm DOUBLE PRECISION,
    product_height_cm DOUBLE PRECISION,
    product_width_cm DOUBLE PRECISION,

    product_volume_cm3 DOUBLE PRECISION,
    product_density_g_cm3 DOUBLE PRECISION,

    has_complete_listing BOOLEAN
);


-- ============================================================
-- 4. SELLERS
-- Grain: One row per seller_id
-- ============================================================

CREATE TABLE sellers_fe (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix TEXT,
    seller_city TEXT,
    seller_state TEXT,
    seller_region TEXT,
    seller_order_count INTEGER
);


-- ============================================================
-- 5. ORDER ITEMS
-- Grain: One row per order_id + order_item_id
-- ============================================================

CREATE TABLE order_items_fe (
    order_id TEXT NOT NULL,
    order_item_id INTEGER NOT NULL,

    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,

    price NUMERIC(18, 4),
    freight_value NUMERIC(18, 4),
    item_total_cost NUMERIC(18, 4),

    freight_ratio DOUBLE PRECISION,

    items_in_order INTEGER,

    order_total_price NUMERIC(18, 4),
    order_total_freight NUMERIC(18, 4),
    order_total_cost NUMERIC(18, 4),

    sellers_in_order INTEGER,
    is_free_shipping BOOLEAN,
    average_item_price NUMERIC(18, 4),

    PRIMARY KEY (order_id, order_item_id)
);


-- ============================================================
-- 6. ORDER PAYMENTS
-- Grain: One row per order_id + payment_sequential
-- ============================================================

CREATE TABLE order_payments_fe (
    order_id TEXT NOT NULL,
    payment_sequential INTEGER NOT NULL,

    payment_type TEXT,
    payment_installments INTEGER,
    payment_value NUMERIC(18, 4),

    PRIMARY KEY (order_id, payment_sequential)
);


-- ============================================================
-- 7. ORDER REVIEWS
-- Grain: One row per order_id in the cleaned dataset
-- ============================================================

CREATE TABLE order_reviews_fe (
    review_id TEXT,
    order_id TEXT PRIMARY KEY,

    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,

    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,

    response_time_hours DOUBLE PRECISION,
    has_comment BOOLEAN,
    review_length INTEGER
);


-- ============================================================
-- 8. MARKETING LEADS
-- Grain: One row per mql_id
-- ============================================================

CREATE TABLE marketing_leads_fe (
    mql_id TEXT PRIMARY KEY,

    first_contact_date TIMESTAMP,
    landing_page_id TEXT,
    origin TEXT,

    contact_year INTEGER,
    contact_month INTEGER,
    contact_quarter TEXT,

    is_organic BOOLEAN
);


-- ============================================================
-- 9. CLOSED DEALS
-- Grain: One row per won mql_id
-- ============================================================

CREATE TABLE closed_deals_fe (
    mql_id TEXT PRIMARY KEY,

    seller_id TEXT,
    sdr_id TEXT,
    sr_id TEXT,

    won_date TIMESTAMP,

    business_segment TEXT,
    lead_type TEXT,
    lead_behaviour_profile TEXT,

    has_company BOOLEAN,
    has_gtin BOOLEAN,

    average_stock TEXT,
    business_type TEXT,

    declared_product_catalog_size TEXT,
    declared_monthly_revenue NUMERIC(18, 4),

    won_year INTEGER,
    won_month INTEGER,
    won_quarter TEXT,

    has_declared_revenue BOOLEAN
);


COMMIT;