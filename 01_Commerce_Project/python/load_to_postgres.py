from pathlib import Path
import csv
import os

import psycopg
from psycopg import sql
from dotenv import load_dotenv

from decimal import Decimal
from io import StringIO


# ============================================================
# 1. PROJECT CONFIGURATION
# ============================================================

PROJECT_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_DIR / "data" / "feature_engineered"

load_dotenv(PROJECT_DIR / ".env")


# ============================================================
# 2. EXPECTED TABLES AND ROW COUNTS
# ============================================================

TABLES = {
    "customers_fe": 99441,
    "orders_fe": 99441,
    "products_fe": 32951,
    "sellers_fe": 3095,
    "order_items_fe": 112650,
    "order_payments_fe": 103886,
    "order_reviews_fe": 98673,
    "marketing_leads_fe": 8000,
    "closed_deals_fe": 842,
}


# ============================================================
# 3. DATABASE CONNECTION
# ============================================================

connection_params = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "5432")),
    "dbname": os.getenv("DB_NAME", "olist_analytics"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD") or None,
}


# ============================================================
# 4. LOAD CSV FILES USING POSTGRESQL COPY
# ============================================================

print("Starting PostgreSQL COPY import...\n")

with psycopg.connect(**connection_params) as conn:

    with conn.cursor() as cur:

        # Clear the nine project tables within one transaction.
        table_identifiers = sql.SQL(", ").join(
            sql.Identifier("public", table_name)
            for table_name in TABLES
        )

        cur.execute(
            sql.SQL("TRUNCATE TABLE {}").format(
                table_identifiers
            )
        )

        for table_name, expected_rows in TABLES.items():

            csv_path = DATA_DIR / f"{table_name}.csv"

            if not csv_path.exists():
                raise FileNotFoundError(csv_path)

            print(f"Loading {table_name}...")

            with open(
                csv_path,
                "r",
                encoding="utf-8-sig",
                newline=""
            ) as csv_file:
                

                reader = csv.reader(csv_file)
                column_names = next(reader)

                # Identify integer columns from PostgreSQL schema.
                cur.execute("""
                    SELECT column_name
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                      AND table_name = %s
                      AND data_type IN (
                          'smallint', 'integer', 'bigint'
                      )
                """, (table_name,))

                integer_columns = {
                    row[0] for row in cur.fetchall()
                }

                integer_indices = [
                    i
                    for i, column in enumerate(column_names)
                    if column in integer_columns
                ]

                copy_query = sql.SQL(
                    "COPY {} ({}) "
                    "FROM STDIN WITH (FORMAT CSV)"
                ).format(
                    sql.Identifier("public", table_name),
                    sql.SQL(", ").join(
                        sql.Identifier(column)
                        for column in column_names
                    )
                )

                with cur.copy(copy_query) as copy:

                    buffer = StringIO()
                    writer = csv.writer(
                        buffer,
                        lineterminator="\n"
                    )

                    for line_number, row in enumerate(
                        reader, start=2
                    ):

                        for index in integer_indices:

                            value = row[index].strip()

                            if value:
                                number = Decimal(value)

                                if number != number.to_integral_value():
                                    raise ValueError(
                                        f"{table_name}, line "
                                        f"{line_number}: "
                                        f"Invalid integer: {value}"
                                    )

                                row[index] = str(int(number))

                        writer.writerow(row)

                        if buffer.tell() >= 1024 * 1024:
                            copy.write(buffer.getvalue())
                            buffer.seek(0)
                            buffer.truncate(0)

                    if buffer.tell():
                        copy.write(buffer.getvalue())

            # Validate the imported row count.
            cur.execute(
                sql.SQL("SELECT COUNT(*) FROM {}").format(
                    sql.Identifier("public", table_name)
                )
            )

            actual_rows = cur.fetchone()[0]

            if actual_rows != expected_rows:
                raise RuntimeError(
                    f"{table_name}: Expected {expected_rows}, "
                    f"found {actual_rows}"
                )

            print(f"  {actual_rows:,} rows | OK")

        # ====================================================
        # 5. VALIDATE CRITICAL MONETARY COLUMNS
        # ====================================================

        cur.execute("""
            SELECT
                COUNT(price),
                COUNT(freight_value)
            FROM public.order_items_fe
        """)

        price_count, freight_count = cur.fetchone()

        cur.execute("""
            SELECT COUNT(payment_value)
            FROM public.order_payments_fe
        """)

        payment_count = cur.fetchone()[0]

        print("\nMonetary data validation:")
        print(f"  Non-null prices: {price_count:,}")
        print(f"  Non-null freight values: {freight_count:,}")
        print(f"  Non-null payment values: {payment_count:,}")

        if min(price_count, freight_count, payment_count) == 0:
            raise RuntimeError(
                "Critical monetary columns contain no values. "
                "Transaction rolled back."
            )

# Transaction commits only if every step succeeds.

print("\nAll 9 tables imported and validated successfully.")