# Medium exercises

18 exercises. Write your answer in `my-answers/<ID>.sql`, then check it with `python3 tools/verify.py <ID>`.

> Row order is only checked when the prompt asks you to sort. Column names do not have to match.


---

## M01 · Revenue by category

**Level:** Medium · **Chapter:** 7 · **Topics:** multi-table JOIN, SUM, GROUP BY

Compute merchandise revenue (sum of quantity * unit_price) per product category, counting only orders  
whose status is 'delivered'. Return category_name and revenue, sorted by revenue descending.

<details><summary>💡 Hint</summary>

The path is orders → order_items → product_variants → products → categories.

</details>

**Expected result** (20 rows, first 5 shown):

| category_name | revenue |
|---|---|
| Laptops | 66688478000 |
| Smartphones | 31603218000 |
| Tablets | 19232646000 |
| Kitchen Appliances | 7435996000 |
| Speakers | 6579983000 |


---

## M02 · Customers who never ordered

**Level:** Medium · **Chapter:** 7 · **Topics:** LEFT JOIN, anti-join

How many customers have never placed a single order (cancelled orders count as orders)?

<details><summary>💡 Hint</summary>

LEFT JOIN, then keep the rows where the right-hand side is NULL — or use NOT EXISTS.

</details>

**Expected result** (1 rows):

| customer_count |
|---|
| 742 |


---

## M03 · Products that never sold

**Level:** Medium · **Chapter:** 8 · **Topics:** NOT EXISTS, subquery

List product_id and name of products that never appear in any order (none of their variants is in  
order_items). Sort by product_id.

**Expected result** (21 rows, first 5 shown):

| product_id | name |
|---|---|
| 27 | NovaTech Office Dress 22 |
| 42 | Face Wash 12 |
| 58 | Hai Au Men's T-Shirt 94 |
| 70 | Truong Son Party Dress 12 |
| 117 | Hai Au Running Shoes 45 |


---

## M04 · Shops with many active products

**Level:** Medium · **Chapter:** 6 · **Topics:** HAVING

Find the shops that have at least 12 active products (is_active). Return shop_name and product_count,  
sorted by product_count descending, then shop_name.

<details><summary>💡 Hint</summary>

WHERE filters rows BEFORE grouping; HAVING filters groups AFTER grouping.

</details>

**Expected result** (5 rows):

| shop_name | product_count |
|---|---|
| Beauty Corner | 16 |
| Tech Market | 14 |
| Digital Shop | 12 |
| Sunlight House | 12 |
| Sunlight World | 12 |


---

## M05 · Employees and their managers

**Level:** Medium · **Chapter:** 7 · **Topics:** SELF JOIN, LEFT JOIN, COALESCE

For every employee, show employee_id, full_name and manager (the name of their direct manager).  
If an employee has no manager, show 'None'. Sort by employee_id.

<details><summary>💡 Hint</summary>

Treat employees as TWO different tables: one playing "employee", one playing "manager".

</details>

**Expected result** (42 rows, first 5 shown):

| employee_id | full_name | manager |
|---|---|---|
| 1 | Lê Minh Yến | None |
| 2 | Phạm Phương Nga | Lê Minh Yến |
| 3 | Nguyễn Mai Diệp | Phạm Phương Nga |
| 4 | Huỳnh Thu Phương | Nguyễn Mai Diệp |
| 5 | Dương Bảo Ngân | Nguyễn Mai Diệp |


---

## M06 · The 10 largest orders

**Level:** Medium · **Chapter:** 6 · **Topics:** GROUP BY, ORDER BY, LIMIT

Compute each order's merchandise subtotal (sum of quantity * unit_price) and return the 10 orders with  
the largest subtotal. Return order_id and subtotal, sorted by subtotal descending, then order_id.

**Expected result** (10 rows, first 5 shown):

| order_id | subtotal |
|---|---|
| 19076 | 217205000 |
| 15903 | 175504000 |
| 15326 | 160840000 |
| 14611 | 160237000 |
| 18540 | 157768000 |


---

## M07 · The NOT IN and NULL trap

**Level:** Medium · **Chapter:** 8 · **Topics:** NOT IN, NOT EXISTS, NULL

How many customers have NEVER referred anyone (their customer_id does not appear in the referred_by column)?  
Try writing it with NOT IN first. Is the answer plausible? Explain why.

<details><summary>💡 Hint</summary>

x NOT IN (1, 2, NULL) is never TRUE. Use NOT EXISTS instead.

</details>

**Expected result** (1 rows):

| customer_count |
|---|
| 2547 |


---

## M08 · Running revenue in 2025

**Level:** Medium · **Chapter:** 10 · **Topics:** WINDOW, SUM OVER

For 'delivered' orders placed in 2025, compute merchandise revenue per month (month: 1–12) and the  
year-to-date running total (running_total). Return month, revenue, running_total, sorted by month.

<details><summary>💡 Hint</summary>

Aggregate per month first (in a CTE), then use SUM(...) OVER (ORDER BY month).

</details>

**Expected result** (12 rows, first 5 shown):

| month | revenue | running_total |
|---|---|---|
| 1 | 8356177000 | 8356177000 |
| 2 | 6179963000 | 14536140000 |
| 3 | 6946332000 | 21482472000 |
| 4 | 7990529000 | 29473001000 |
| 5 | 8437828000 | 37910829000 |


---

## M09 · Month-over-month order growth

**Level:** Medium · **Chapter:** 10 · **Topics:** LAG, WINDOW

For every month in the data, show month (as 'YYYY-MM'), order_count, and growth_pct =  
(order_count - previous month's order_count) * 100 / previous month's order_count, rounded to 1 decimal.  
The first month has a NULL growth. Sort by month.

**Expected result** (24 rows, first 5 shown):

| month | order_count | growth_pct |
|---|---|---|
| 2024-01 | 699 | *NULL* |
| 2024-02 | 596 | -14.7 |
| 2024-03 | 627 | 5.2 |
| 2024-04 | 581 | -7.3 |
| 2024-05 | 632 | 8.8 |


---

## M10 · Order value buckets

**Level:** Medium · **Chapter:** 11 · **Topics:** CASE, GROUP BY

Put every order into a bucket by its subtotal (sum of quantity * unit_price):  
'Under 200k' (< 200,000), '200k-500k' (< 500,000), '500k-2M' (< 2,000,000), '2M and up' (everything else).  
Return bucket and order_count.

**Expected result** (4 rows):

| bucket | order_count |
|---|---|
| 2M and up | 10145 |
| Under 200k | 857 |
| 500k-2M | 6128 |
| 200k-500k | 2870 |


---

## M11 · Cancellation rate by region

**Level:** Medium · **Chapter:** 11 · **Topics:** JOIN, FILTER / CASE, ratios

By the region of the shipping address, compute total_orders, cancelled_orders (status = 'cancelled') and  
cancel_rate_pct = cancelled_orders * 100 / total_orders, rounded to 2 decimals.

<details><summary>💡 Hint</summary>

COUNT(*) FILTER (WHERE ...) or SUM(CASE WHEN ... THEN 1 ELSE 0 END). Watch out for integer division!

</details>

**Expected result** (3 rows):

| region | total_orders | cancelled_orders | cancel_rate_pct |
|---|---|---|---|
| South | 7072 | 684 | 9.67 |
| North | 8115 | 813 | 10.02 |
| Central | 4813 | 467 | 9.70 |


---

## M12 · Which carrier is fastest?

**Level:** Medium · **Chapter:** 11 · **Topics:** time, AVG, EPOCH

For shipments that have been delivered (delivered_at is not NULL), compute per carrier: carrier_name,  
shipment_count, and avg_days = average number of days from shipped_at to delivered_at (rounded to 2 decimals).  
Sort by avg_days ascending.

<details><summary>💡 Hint</summary>

EXTRACT(EPOCH FROM an_interval) returns the number of seconds.

</details>

**Expected result** (4 rows):

| carrier_name | shipment_count | avg_days |
|---|---|---|
| PostTrust | 3573 | 2.45 |
| Camel Logistics | 1752 | 2.45 |
| SwiftShip | 7052 | 2.46 |
| Swallow Express | 5485 | 2.46 |


---

## M13 · Coupon users who also returned goods

**Level:** Medium · **Chapter:** 8 · **Topics:** EXISTS

Count the customers who satisfy BOTH conditions: they have placed an order using a coupon, AND they have  
an order with status 'returned'. (The two conditions may be met by different orders.)

**Expected result** (1 rows):

| customer_count |
|---|
| 543 |


---

## M14 · In stock in Hanoi, not in HCMC

**Level:** Medium · **Chapter:** 9 · **Topics:** EXCEPT

Count the variants that are in stock (quantity > 0) at 'Hanoi Warehouse' but NOT in stock at  
'HCMC Warehouse' (including variants HCMC does not carry at all).

**Expected result** (1 rows):

| variant_count |
|---|
| 196 |


---

## M15 · September birthdays who bought in 2025

**Level:** Medium · **Chapter:** 11 · **Topics:** EXTRACT, EXISTS

List customer_id, full_name and birth_date of customers born in September who placed at least one order  
in 2025. Sort by customer_id.

<details><summary>💡 Hint</summary>

If you JOIN orders directly, a customer with many orders appears many times.

</details>

**Expected result** (133 rows, first 5 shown):

| customer_id | full_name | birth_date |
|---|---|---|
| 8 | Nguyễn Quang Việt | 1998-09-03 |
| 35 | Trần Phương Dung | 1971-09-06 |
| 49 | Nguyễn Thị Thảo | 2006-09-24 |
| 146 | Đỗ Hữu Dũng | 1969-09-05 |
| 153 | Nguyễn Văn Hùng | 1996-09-18 |


---

## M16 · Peak order days

**Level:** Medium · **Chapter:** 6 · **Topics:** HAVING, casting to date

Which days of 2025 had more than 100 orders? Return day (a date) and order_count, sorted by day.  
What pattern do you notice?

**Expected result** (4 rows):

| day | order_count |
|---|---|
| 2025-09-09 | 102 |
| 2025-10-10 | 110 |
| 2025-11-11 | 138 |
| 2025-12-12 | 121 |


---

## M17 · The row-multiplication trap

**Level:** Medium · **Chapter:** 7 · **Topics:** fan-out, COUNT DISTINCT

For 'delivered' orders, compute per shop: order_count (number of DISTINCT orders containing that shop's  
products) and units (total quantity sold). Return the 10 shops with the most units.  
Columns: shop_name, order_count, units; sort by units descending, then shop_name.

<details><summary>💡 Hint</summary>

An order with 3 line items from the same shop is counted 3 times by COUNT(*).

</details>

**Expected result** (10 rows, first 5 shown):

| shop_name | order_count | units |
|---|---|---|
| Digital Depot | 1597 | 1982 |
| Beauty Corner | 1534 | 1925 |
| Peaceful Mart | 1038 | 1290 |
| Digital House | 811 | 1005 |
| Thoi Trang Store | 764 | 960 |


---

## M18 · How much do loyal customers spend per order?

**Level:** Medium · **Chapter:** 8 · **Topics:** CTE, two-level aggregation

Consider only 'delivered' orders. For customers with at least 30 such orders, compute order_count and  
avg_order_value = the average subtotal PER ORDER (rounded to a whole number). Return customer_id, full_name,  
order_count, avg_order_value; sort by avg_order_value descending, then customer_id.

<details><summary>💡 Hint</summary>

AVG(quantity * unit_price) averages LINE ITEMS, not ORDERS. Aggregate per order first.

</details>

**Expected result** (63 rows, first 5 shown):

| customer_id | full_name | order_count | avg_order_value |
|---|---|---|---|
| 787 | Nguyễn Văn Phong | 50 | 15491160 |
| 365 | Lê Thanh Quyên | 33 | 13688364 |
| 1952 | Đặng Thanh Lan | 42 | 13504429 |
| 773 | Vũ Thanh Nhung | 52 | 13112923 |
| 1156 | Dương Anh Khang | 41 | 12185024 |
