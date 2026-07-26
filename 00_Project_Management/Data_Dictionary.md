The number of customer_unique_ids is less than the total number of customer_ids. This means there are multiple rows with some identical unique_ids.
The `customer_zip_code_prefix` field is stored as an int64, but this is a categorical/descriptive field, not a numerical measure. For example, aggregate statistics like mean/standard deviation are meaningless here. Therefore, I will convert it to a string during the cleanup phase.

This code shows how many different rows (i.e., how many different customer_IDs) each customer_unique_id appears in the customers table. For example, the actual customer named 8d50f5eadf50201ccdcedfb9e2ac8455 is registered with 17 different customer_IDs in the table. A single customer appears to have multiple customer records. The underlying business reason is currently unknown and requires further investigation. For example, the same person may have placed orders using different email addresses, or a customer may have deleted their account and then registered again; such business rules may apply.

I answered the question "How many customer_unique_id instances occur more than once?" in the relevant sections.
Approximately 3% of Nova7's total unique customers appear under multiple customer_IDs in the system. This indicates that we should use customer_unique_ID instead of customer_ID in "repeat customer" analytics; otherwise, we might mistakenly count the same person as multiple different customers.

Most of the orders have been delivered. However, there are 7 more cases besides those. I checked the numbers for each one.

Some orders with blank delivery dates have been shipped, some have been cancelled, some are out of stock, etc. However, 8 orders show "delivered" but the "order_delivered_customer_date" section is empty. This is a data quality issue. There may be missing or incorrectly entered data.

I'm curious about the date range covered by the dataset. I might need this for time-based trend analysis. Here, I converted the string to datetime because it's more accurate to work with date columns as datetimes.

I examined the number of orders per month. This part is important for analyzing how order volume progresses. Some months show a significant decrease compared to others. There may have been an interruption during the data collection period. If so, I will remove these periods from the trend analysis. It's important that we notice these things, otherwise misinterpretations can occur. 

The table has 112,650 rows, more than the number of rows in the orders table. This is because an order can contain multiple products, and therefore order_items has more rows.

The order_item_id value is max=21. This means there are 21 different products in one order. This could be a bulk purchase.

In the price column, the standard deviation is even larger than the mean itself. This means the data isn't evenly distributed around the mean; it's spread over a wide range. A right-skewed distribution is present. Most products are cheap, but a small number of expensive products are pushing the mean and standard deviation upwards.

In such cases, the median is more reliable than the mean. When I create a visualization of the average value of orders in the future, I should not ignore these values.

There are orders where the freight_value min = 0.00, meaning the shipping cost is zero. This might be a "free shipping" order, but I'm checking anyway.
There are 383 orders like this, and based on my dataset, it's a logical scenario.

The max=29 for `payment_sequential` is a noteworthy number. Different payment methods might have been used, but 29 doesn't seem very realistic. The system might have given an error, the customer might have tried repeatedly, the system might have split the payment, or it could be a data structure issue.
Again, there's a large difference between the maximum payout amount and the average, and the standard deviation remains above the average. As above, payouts are generally in the lower range, but some are higher than the average. I can confirm this from the 75% figure as well.
Order IDs can be repeated in this table. In fact, this table has more rows than the orders table because an order can be paid for in multiple ways, and a separate record is created for each payment method.

There can be multiple reasons for a high `payment_sequential` value. To understand this, I examined the payment type in cases where there were more than 10 sequential payments. According to this output, a customer used multiple coupons in the same order, and the system recorded each coupon as a separate payment.
I wanted to examine the order with 29 payment records separately.

As you can see, all records are of the voucher type. There are two 0.00 values, and the amounts are different from each other. These 0.00 values ​​could have several causes. It could be a cancelled voucher, a technical issue, or a rounding error.

Mostly rated 5 stars. However, this dataset only contains customers who submitted reviews, so it may not represent the satisfaction of all customers.

Review scores show a polarized (bimodal-leaning) pattern: 5-star is most common, but 1-star ranks third — more common than 2-3 star. This is a typical pattern in customer feedback, where neutral experiences are less likely to prompt a review than very positive or very negative ones.

The `order_reviews` table normally has 99,225 rows, but there are 98,673 different `order_id` in the table. This suggests that some orders have multiple reviews. This must be handled carefully during merging — a naive merge could duplicate order-level data. Will likely take the latest review per order, or aggregate review scores, during the cleaning phase.

Logically, the `review_answer_timestamp` should always come after the `review_creation_date`. This is because a reply to a comment comes after the comment is written. I tested this here, and it's consistent. If it weren't 0, there might be a data quality anomaly.

I examined how many days it typically takes to respond to a review. The average is 2.5 days, but the standard deviation is very high (9.89) — this is driven by extreme outliers, with a maximum of 518 days. Since review_answer_timestamp has no nulls, every review does have a recorded response — but some responses took an unusually long time, possibly due to delayed processing or batch handling on the platform's side. Looking at the quartiles (25%: 1 day, 50%: 1 day, 75%: 3 days), the typical response time is much shorter than the mean suggests — again, median is more representative here than mean.

The minimum value entered for weight appears to be "0". I checked how many of these there are.

I checked what these four products are. They all belong to the same category: "bed, table, bathroom". The weight field might have been overlooked during data entry, a standard template might have been used, or the system might have accepted 0 if it wasn't a required entry. I will correct this during data cleaning.

Some rows contain 610 null values, while others contain only 2. Using this code, I calculated the number of rows that are empty simultaneously in both the "product_category_name" and "product_weight_g" columns. Since there's only one, these two issues are likely unrelated. This simplifies the cleanup process.

This shows which states the sellers are concentrated in. The state of SP is dominant on both the buyer and seller sides.
sdr_id and sr_id; the IDs of the sales representatives who closed the deal, namely the Sales Development Rep and the Sales Rep.
won_date; the date the deal was closed/won.
business_segment, business_type; the seller's business type and sector.
has_company, has_gtin; fields such as "does the company have registration, does it have a product barcode system (GTIN)?".
declared_product_catalog_size, declared_monthly_revenue — the seller's self-declared catalog size and monthly revenue.

The columns `has_company`, `has_gtin`, and `declared_product_catalog_size` contain many null values. This is a high number, so it's probably not a random omission. They could be optional form questions or fields added later and recently asked. This missing data issue needs to be addressed in the analytics section.

declared_monthly_revenue is heavily skewed: median is 0, mean is ~73K, but max is 50M — a small number of large sellers pull the average far above the typical value. Zero may mean 'no revenue yet' (new sellers) or could be a placeholder for 'not declared' — this ambiguity will be noted, not resolved, since we can't confirm from the data alone.

`first_contact_date` is the date the lead first made contact, `landing_page_id` is the landing page they came from, and `origin` is the marketing source.

This checks if all mql_id's in closed_deals actually exist in the marketing_leads table. If it returns True, the relationship between the two tables is consistent, so I can confidently join them.
If it returns False, some closed_deals would be missing source lead records.

The marketing_leads table has 8000 rows, while the closed_deals table has 842 rows. This means some of them have converted to resellers. This allows me to calculate the conversion rate.
Approximately 1 out of every 10 leads captured by marketing turns into an actual salesperson.

--BURAYA KADARKİ KISIM TABLOLARIN YÜZEYSEL İNCELENMESİ--

