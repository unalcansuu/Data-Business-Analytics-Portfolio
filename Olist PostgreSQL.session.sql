
ALTER TABLE public.closed_deals_fe
    ALTER COLUMN average_stock TYPE TEXT
        USING average_stock::TEXT,
    ALTER COLUMN declared_product_catalog_size TYPE TEXT
        USING declared_product_catalog_size::TEXT;