# Easy exercises

20 exercises. Write your answer in `my-answers/<ID>.sql`, then check it with `python3 tools/verify.py <ID>`.

> Row order is only checked when the prompt asks you to sort. Column names do not have to match.


---

## E01 · Provinces in the Central region

**Level:** Easy · **Chapter:** 3 · **Topics:** SELECT, WHERE, ORDER BY

List the name of every province in the 'Central' region, sorted by name.

<details><summary>💡 Hint</summary>

The provinces table has a region column.

</details>

**Expected result** (11 rows, first 5 shown):

| name |
|---|
| Da Nang |
| Dak Lak |
| Gia Lai |
| Ha Tinh |
| Hue |


---

## E02 · The 10 most expensive variants

**Level:** Easy · **Chapter:** 3 · **Topics:** ORDER BY, LIMIT

Return sku, variant_name and price of the 10 product variants with the highest price.  
Break ties by sku (ascending).

<details><summary>💡 Hint</summary>

With ORDER BY on several columns, the second column only matters when the first one ties.

</details>

**Expected result** (10 rows, first 5 shown):

| sku | variant_name | price |
|---|---|---|
| SKU-0083-3 | 512GB | 56073000 |
| SKU-0483-3 | 512GB | 55845000 |
| SKU-0397-3 | 512GB | 51602000 |
| SKU-0158-2 | White | 50539000 |
| SKU-0083-2 | 256GB | 49603000 |


---

## E03 · Customers who signed up in December 2025

**Level:** Easy · **Chapter:** 3 · **Topics:** WHERE, date range

List customer_id, full_name and signup_date of customers who signed up in December 2025.  
Sort by signup_date, then customer_id.

<details><summary>💡 Hint</summary>

Use a half-open range: >= '2025-12-01' AND < '2026-01-01'.

</details>

**Expected result** (134 rows, first 5 shown):

| customer_id | full_name | signup_date |
|---|---|---|
| 1192 | Đỗ Bảo Hoa | 2025-12-01 |
| 1477 | Hoàng Khánh Giang | 2025-12-01 |
| 1588 | Võ Hữu Dũng | 2025-12-01 |
| 1632 | Trần Minh Dũng | 2025-12-01 |
| 2677 | Lê Minh Hà | 2025-12-01 |


---

## E04 · Customers without a phone number

**Level:** Easy · **Chapter:** 4 · **Topics:** NULL, COUNT

How many customers have no phone number?

<details><summary>💡 Hint</summary>

phone = NULL is never true. Use IS NULL.

</details>

**Expected result** (1 rows):

| customer_count |
|---|
| 384 |


---

## E05 · Unbranded products

**Level:** Easy · **Chapter:** 4 · **Topics:** NULL

List product_id and name of products that have no brand, sorted by product_id.

**Expected result** (30 rows, first 5 shown):

| product_id | name |
|---|---|
| 4 | Men's T-Shirt 28 |
| 42 | Face Wash 12 |
| 59 | Portable Speaker 33 |
| 94 | Face Wash 12 |
| 121 | Book: Soft Skills 43 |


---

## E06 · Payment methods in use

**Level:** Easy · **Chapter:** 3 · **Topics:** DISTINCT

List every payment method that appears in the payments table, without duplicates.

**Expected result** (4 rows):

| method |
|---|
| ewallet |
| bank_transfer |
| card |
| cod |


---

## E07 · Orders by status

**Level:** Easy · **Chapter:** 6 · **Topics:** GROUP BY, COUNT

Count orders per status. Return status and order_count, sorted by order_count descending.

**Expected result** (6 rows, first 5 shown):

| status | order_count |
|---|---|
| delivered | 16879 |
| cancelled | 1964 |
| returned | 983 |
| shipped | 108 |
| paid | 42 |


---

## E08 · Total stock per warehouse

**Level:** Easy · **Chapter:** 6 · **Topics:** GROUP BY, SUM

For each warehouse, compute the total quantity in stock. Return warehouse_id and total_stock,  
sorted by warehouse_id.

**Expected result** (3 rows):

| warehouse_id | total_stock |
|---|---|
| 1 | 153233 |
| 2 | 156973 |
| 3 | 150862 |


---

## E09 · Percentage coupons

**Level:** Easy · **Chapter:** 3 · **Topics:** WHERE, ORDER BY

List code, discount_value and valid_from of all coupons whose discount_type is 'percent'.  
Sort by valid_from, then code.

**Expected result** (25 rows, first 5 shown):

| code | discount_value | valid_from |
|---|---|---|
| MONTH01-2024 | 10 | 2024-01-01 |
| MONTH02-2024 | 10 | 2024-02-01 |
| MONTH03-2024 | 10 | 2024-03-01 |
| MONTH04-2024 | 10 | 2024-04-01 |
| MONTH05-2024 | 10 | 2024-05-01 |


---

## E10 · Well-paid customer service staff

**Level:** Easy · **Chapter:** 3 · **Topics:** WHERE, AND

List full_name and salary of employees in the 'Customer Service' department earning more than 15,000,000.  
Sort by salary descending, then full_name.

**Expected result** (6 rows, first 5 shown):

| full_name | salary |
|---|---|
| Nguyễn Tuấn Hùng | 66500000 |
| Nguyễn Thanh Yến | 33000000 |
| Đặng Thành Toàn | 18000000 |
| Huỳnh Anh Phúc | 16700000 |
| Trần Anh Long | 16100000 |


---

## E11 · Marketplace average rating

**Level:** Easy · **Chapter:** 6 · **Topics:** AVG, ROUND

Compute the number of reviews (review_count) and the average rating (avg_rating, rounded to 2 decimals)  
across the whole marketplace.

**Expected result** (1 rows):

| review_count | avg_rating |
|---|---|
| 8346 | 4.29 |


---

## E12 · Products and their categories

**Level:** Easy · **Chapter:** 7 · **Topics:** INNER JOIN

For the 20 products with the smallest product_id, show product_id, the product name (product_name)  
and the category name (category_name).

<details><summary>💡 Hint</summary>

Both tables have a column called name — give each one an alias.

</details>

**Expected result** (20 rows, first 5 shown):

| product_id | product_name | category_name |
|---|---|---|
| 1 | Kira Office Dress 24 | Dresses |
| 2 | Phuong Hoang Stainless Pot Set 56 | Cookware |
| 3 | Mekong Running Shoes 99 | Sneakers |
| 4 | Men's T-Shirt 28 | Men's Shirts |
| 5 | Lotus Non-Stick Pan 82 | Cookware |


---

## E13 · Line items of order 246

**Level:** Easy · **Chapter:** 7 · **Topics:** JOIN, expressions

List the line items of order 246: sku, variant_name, quantity, unit_price and  
line_total = quantity * unit_price. Sort by sku.

**Expected result** (3 rows):

| sku | variant_name | quantity | unit_price | line_total |
|---|---|---|---|---|
| SKU-0068-2 | Premium | 2 | 582000 | 1164000 |
| SKU-0242-2 | Premium | 1 | 324000 | 324000 |
| SKU-0280-1 | Default | 1 | 27891000 | 27891000 |


---

## E14 · Customers by gender

**Level:** Easy · **Chapter:** 6 · **Topics:** GROUP BY, COALESCE, NULL

Count customers by gender. The gender column should show 'M', 'F', or 'Unknown' (when gender is NULL);  
the count column is customer_count.

<details><summary>💡 Hint</summary>

GROUP BY puts all NULLs into the same group.

</details>

**Expected result** (3 rows):

| gender | customer_count |
|---|---|
| Unknown | 144 |
| M | 1452 |
| F | 1404 |


---

## E15 · Orders per month in 2025

**Level:** Easy · **Chapter:** 11 · **Topics:** EXTRACT, GROUP BY

Count the orders placed in each month of 2025. Return month (a number 1–12) and order_count, sorted by month.

**Expected result** (12 rows, first 5 shown):

| month | order_count |
|---|---|
| 1 | 1051 |
| 2 | 819 |
| 3 | 902 |
| 4 | 841 |
| 5 | 910 |


---

## E16 · Shipments still in transit

**Level:** Easy · **Chapter:** 4 · **Topics:** IS NULL

List shipment_id and order_id of shipments that have not been delivered yet (no delivered_at).  
Sort by shipment_id.

**Expected result** (108 rows, first 5 shown):

| shipment_id | order_id |
|---|---|
| 17805 | 19764 |
| 17806 | 19765 |
| 17809 | 19769 |
| 17811 | 19771 |
| 17812 | 19772 |


---

## E17 · Where are the official stores?

**Level:** Easy · **Chapter:** 7 · **Topics:** JOIN, boolean

List shop_name and the province name (province_name) of every official store (is_official).  
Sort by shop_name.

**Expected result** (14 rows, first 5 shown):

| shop_name | province_name |
|---|---|
| Beauty Market | Hanoi |
| Digital Depot | Ho Chi Minh City |
| Digital Shop | Thanh Hoa |
| Green Market | Lam Dong |
| Handy Mart | Dong Nai |


---

## E18 · Emails with capital letters

**Level:** Easy · **Chapter:** 11 · **Topics:** LOWER, strings

Find customer_id and email of customers whose email contains at least one uppercase letter.  
Sort by customer_id.

<details><summary>💡 Hint</summary>

A string without uppercase letters is equal to its own LOWER().

</details>

**Expected result** (99 rows, first 5 shown):

| customer_id | email |
|---|---|
| 57 | Phuc.nguyen57@gmail.com |
| 66 | Anh.dang66@gmail.com |
| 87 | Thang.pham87@yahoo.com |
| 117 | Phong.nguyen117@gmail.com |
| 150 | Phong.le150@gmail.com |


---

## E19 · Top 5 provinces by customers

**Level:** Easy · **Chapter:** 7 · **Topics:** JOIN, GROUP BY, LIMIT

Using each customer's DEFAULT address, find the 5 provinces with the most customers.  
Return province_name and customer_count; sort by customer_count descending, then province_name.

**Expected result** (5 rows):

| province_name | customer_count |
|---|---|
| Ho Chi Minh City | 602 |
| Hanoi | 550 |
| Da Nang | 145 |
| Dong Nai | 123 |
| Hai Phong | 120 |


---

## E20 · Provinces with a warehouse or a shop

**Level:** Easy · **Chapter:** 9 · **Topics:** UNION

List (without duplicates) the province_id of every province that has a warehouse OR at least one shop.

**Expected result** (23 rows, first 5 shown):

| province_id |
|---|
| 29 |
| 31 |
| 14 |
| 22 |
| 13 |
