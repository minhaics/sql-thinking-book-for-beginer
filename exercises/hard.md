# Hard exercises

12 exercises. Write your answer in `my-answers/<ID>.sql`, then check it with `python3 tools/verify.py <ID>`.

> Row order is only checked when the prompt asks you to sort. Column names do not have to match.


---

## H01 · Best-selling product in every category

**Level:** Hard · **Chapter:** 10 · **Topics:** top-N per group, RANK

For each product category, find the product with the highest total quantity sold in 'delivered' orders.  
If several products tie for first place, list all of them. Return category_name, product_name, units.

<details><summary>💡 Hint</summary>

MAX() cannot bring along "the name that goes with it". Rank inside each group: RANK() OVER (PARTITION BY ...).

</details>

**Expected result** (20 rows, first 5 shown):

| category_name | product_name | units |
|---|---|---|
| Smartphones | Nexus Phone 32 | 484 |
| Tablets | NovaTech Tab 94 | 250 |
| Laptops | Apex Laptop 97 | 475 |
| Keyboards & Mice | Summit Mechanical Keyboard K18 | 156 |
| Headphones | Pulse Bluetooth Headphones 87 | 196 |


---

## H02 · Revenue rolled up to top-level categories

**Level:** Hard · **Chapter:** 12 · **Topics:** RECURSIVE CTE, trees, LEFT JOIN

Categories form a tree (parent_id). Products are attached only to leaf categories. Roll merchandise revenue  
('delivered' orders) up to every TOP-LEVEL category (parent_id IS NULL), including top-level categories with no  
revenue (show 0). Return top_category and revenue, sorted by revenue descending, then top_category.

<details><summary>💡 Hint</summary>

Use WITH RECURSIVE to map every category to its top-level ancestor (root_id).

</details>

**Expected result** (6 rows, first 5 shown):

| top_category | revenue |
|---|---|
| Electronics | 128682490000 |
| Home & Living | 11198408000 |
| Fashion | 10484270000 |
| Beauty & Health | 3092805000 |
| Books & Stationery | 1066473000 |


---

## H03 · Org chart paths

**Level:** Hard · **Chapter:** 12 · **Topics:** RECURSIVE CTE, paths

For every employee, show employee_id, level (the head of the company = 1, their direct reports = 2, ...)  
and path: the names from the head of the company down to the employee, joined with ' > '. Sort by employee_id.

**Expected result** (42 rows, first 5 shown):

| employee_id | level | path |
|---|---|---|
| 1 | 1 | Deborah Williams |
| 2 | 2 | Deborah Williams > Margaret Brown |
| 3 | 3 | Deborah Williams > Margaret Brown > Jennifer Smith |
| 4 | 4 | Deborah Williams > Margaret Brown > Jennifer Smith > Emily Garcia |
| 5 | 4 | Deborah Williams > Margaret Brown > Jennifer Smith > Sandra Taylor |


---

## H04 · 90-day repeat purchase rate by cohort

**Level:** Hard · **Chapter:** 13 · **Topics:** cohort, retention, CTE, EXISTS

Ignore 'cancelled' orders. A customer's cohort is the month of their first order. For the cohorts of 2024,  
compute: cohort ('YYYY-MM'), customer_count, repeat_customers (customers with at least one OTHER order placed  
AFTER their first order and no more than 90 days after it), and repeat_rate_pct (rounded to 1 decimal).  
Sort by cohort.

**Expected result** (12 rows, first 5 shown):

| cohort | customer_count | repeat_customers | repeat_rate_pct |
|---|---|---|---|
| 2024-01 | 323 | 282 | 87.3 |
| 2024-02 | 118 | 94 | 79.7 |
| 2024-03 | 93 | 68 | 73.1 |
| 2024-04 | 66 | 48 | 72.7 |
| 2024-05 | 83 | 69 | 83.1 |


---

## H05 · Longest streak of consecutive buying months

**Level:** Hard · **Chapter:** 13 · **Topics:** gaps and islands, ROW_NUMBER

Ignore 'cancelled' orders. For each customer, find the longest run of CONSECUTIVE months in which they placed  
at least one order. If a customer has several runs of the same length, take the earliest. List the 10 customers  
with the longest runs: customer_id, months, from_month ('YYYY-MM'), to_month ('YYYY-MM');  
sort by months descending, then customer_id.

<details><summary>💡 Hint</summary>

The "gaps and islands" trick: (month_number - ROW_NUMBER()) is constant within one consecutive run.

</details>

**Expected result** (10 rows, first 5 shown):

| customer_id | months | from_month | to_month |
|---|---|---|---|
| 760 | 24 | 2024-01 | 2025-12 |
| 1786 | 24 | 2024-01 | 2025-12 |
| 1848 | 24 | 2024-01 | 2025-12 |
| 1922 | 24 | 2024-01 | 2025-12 |
| 1929 | 24 | 2024-01 | 2025-12 |


---

## H06 · Customers who come back fastest

**Level:** Hard · **Chapter:** 10 · **Topics:** LAG, intervals

Ignore 'cancelled' orders. For customers with at least 5 orders, compute avg_days = the average number of days  
between two consecutive orders (rounded to 1 decimal). Return the 10 customers with the smallest avg_days:  
customer_id, order_count, avg_days; sort by avg_days ascending, then customer_id.

**Expected result** (10 rows, first 5 shown):

| customer_id | order_count | avg_days |
|---|---|---|
| 2544 | 5 | 2.7 |
| 1786 | 169 | 4.3 |
| 590 | 13 | 4.7 |
| 1624 | 127 | 4.7 |
| 652 | 92 | 4.9 |


---

## H07 · Payment reconciliation

**Level:** Hard · **Chapter:** 13 · **Topics:** reconciliation, multiple CTEs, CASE, GREATEST

Accounting suspects the system collected the wrong amounts. For each 'delivered' order the EXPECTED amount is  
  expected = GREATEST(subtotal - discount, 0) + shipping_fee  
where discount = ROUND(subtotal * discount_value / 100, -3) for a 'percent' coupon, = discount_value for a 'fixed'  
coupon, and 0 when no coupon was used. The COLLECTED amount is the sum of the order's payments with status  
'success'. List the mismatching orders: order_id, expected, collected, difference (= collected - expected),  
sorted by order_id.

<details><summary>💡 Hint</summary>

Aggregate order_items and payments in TWO separate CTEs before joining — joining them at once multiplies rows.

</details>

**Expected result** (38 rows, first 5 shown):

| order_id | expected | collected | difference |
|---|---|---|---|
| 266 | 1990000 | 1972000 | -18000 |
| 303 | 1272000 | 1282000 | 10000 |
| 588 | 423000 | 405000 | -18000 |
| 1834 | 624000 | 634000 | 10000 |
| 2752 | 2291000 | 2301000 | 10000 |


---

## H08 · 7-day moving average in November 2025

**Level:** Hard · **Chapter:** 10 · **Topics:** WINDOW FRAME, ROWS BETWEEN, filtering too early

Compute daily merchandise revenue for orders that were not cancelled (status <> 'cancelled'), and its 7-day  
moving average (the current day plus the 6 previous days, rounded to a whole number). SHOW only the days of  
November 2025, but the average for Nov 1 must still use the last days of October.  
Return day, revenue, avg_7d; sort by day.

<details><summary>💡 Hint</summary>

If you filter November in WHERE, the window cannot "see" October. Compute the window first, filter afterwards.
(Every day has orders, so ROWS 6 PRECEDING equals 7 calendar days here.)

</details>

**Expected result** (30 rows, first 5 shown):

| day | revenue | avg_7d |
|---|---|---|
| 2025-11-01 | 291868000 | 353427714 |
| 2025-11-02 | 294322000 | 335887714 |
| 2025-11-03 | 310555000 | 335697143 |
| 2025-11-04 | 303438000 | 342996571 |
| 2025-11-05 | 277576000 | 318954571 |


---

## H09 · Region × quarter pivot table

**Level:** Hard · **Chapter:** 11 · **Topics:** pivot, FILTER

For orders placed in 2025, build a table of order counts: one row per quarter (quarter: 1–4) and the columns  
north, central, south holding the number of orders shipped to each region. Sort by quarter.

**Expected result** (4 rows):

| quarter | north | central | south |
|---|---|---|---|
| 1 | 1132 | 663 | 977 |
| 2 | 1043 | 609 | 958 |
| 3 | 1189 | 718 | 1049 |
| 4 | 1282 | 775 | 1201 |


---

## H10 · Customers loyal to a product

**Level:** Hard · **Chapter:** 8 · **Topics:** COUNT DISTINCT, JOIN, HAVING

Ignore 'cancelled' orders. Find the (customer, product) pairs where the customer bought that product in at  
least 6 DIFFERENT orders (different variants of the same product count as the same product).  
Return customer_id, product_id, order_count; sort by order_count descending, then customer_id, product_id.

**Expected result** (30 rows, first 5 shown):

| customer_id | product_id | order_count |
|---|---|---|
| 328 | 68 | 13 |
| 1030 | 68 | 11 |
| 652 | 68 | 10 |
| 760 | 68 | 9 |
| 1786 | 242 | 9 |


---

## H11 · Frequently bought together

**Level:** Hard · **Chapter:** 13 · **Topics:** self join, market basket

Find the 10 pairs of PRODUCTS (product_a < product_b) that appear together in the largest number of orders.  
Return product_a, product_b, order_count; sort by order_count descending, then product_a, product_b.

<details><summary>💡 Hint</summary>

Self-join the "order–product" list on order_id, with a < b so each pair is counted once.

</details>

**Expected result** (10 rows, first 5 shown):

| product_a | product_b | order_count |
|---|---|---|
| 68 | 242 | 28 |
| 68 | 269 | 27 |
| 68 | 145 | 24 |
| 185 | 269 | 24 |
| 30 | 68 | 23 |


---

## H12 · Median order value by region

**Level:** Hard · **Chapter:** 11 · **Topics:** PERCENTILE_CONT, mean vs median

For 'delivered' orders, compute per shipping region: region, mean (AVG subtotal, rounded to a whole number)  
and median (median subtotal, rounded to a whole number). Why is the mean so much larger than the median?

**Expected result** (3 rows):

| region | mean | median |
|---|---|---|
| Central | 9279145 | 2145000 |
| North | 9382734 | 2074000 |
| South | 8809914 | 2111000 |
