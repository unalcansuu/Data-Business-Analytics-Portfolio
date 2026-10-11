from pathlib import Path
import pandas as pd

# Locate the project and feature-engineered CSV files
PROJECT_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_DIR / "data" / "feature_engineered"

csv_files = sorted(DATA_DIR.glob("*_fe.csv"))

if not csv_files:
    raise FileNotFoundError(
        f"No feature-engineered CSV files found in {DATA_DIR}"
    )

# Inspect each table before creating the PostgreSQL schema
for file_path in csv_files:
    df = pd.read_csv(file_path, low_memory=False)

    print(f"\n{'=' * 65}")
    print(f"TABLE: {file_path.stem}")
    print(f"ROWS: {len(df):,} | COLUMNS: {len(df.columns)}")
    print(f"{'=' * 65}")

    print("\nColumn names:")
    print(", ".join(df.columns))

    print("\nPotential key columns:")

    key_candidates = [
        "order_id",
        "order_item_id",
        "customer_id",
        "customer_unique_id",
        "review_id",
        "seller_id",
        "mql_id"
    ]

    for column in key_candidates:
        if column in df.columns:
            print(
                f"{column}: "
                f"unique={df[column].nunique():,}, "
                f"missing={df[column].isna().sum():,}"
            )

    print("\nDate/time candidates:")
    date_columns = [
        column for column in df.columns
        if "date" in column.lower()
        or "timestamp" in column.lower()
    ]
    print(date_columns)

print("\nSource inspection completed.")

# Validate candidate primary keys

key_checks = {
    "orders_fe": ["order_id"],
    "customers_fe": ["customer_id"],
    "order_items_fe": ["order_id", "order_item_id"],
    "order_payments_fe": ["order_id", "payment_sequential"],
    "order_reviews_fe": ["order_id"],
    "products_fe": ["product_id"],
    "sellers_fe": ["seller_id"],
    "marketing_leads_fe": ["mql_id"],
    "closed_deals_fe": ["mql_id"]
}

print("\nPRIMARY KEY VALIDATION")

for table_name, key_columns in key_checks.items():
    file_path = DATA_DIR / f"{table_name}.csv"
    df = pd.read_csv(file_path, low_memory=False)

    duplicate_count = df.duplicated(subset=key_columns).sum()
    missing_count = df[key_columns].isna().any(axis=1).sum()

    print(
        f"{table_name}: "
        f"duplicate_keys={duplicate_count}, "
        f"missing_keys={missing_count}"
    )