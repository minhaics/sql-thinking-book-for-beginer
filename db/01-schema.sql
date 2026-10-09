-- =====================================================================
--  CHO NHA TA — practice database for "SQL Thinking for Beginners"
--  Engine: PostgreSQL 16+
--  Normalized to 3NF (derived values such as an order's total are NOT stored)
--
--  17 tables in 5 business areas:
--    1. Places & people     : provinces, customers, addresses, employees
--    2. Sellers & catalog   : sellers, categories, products, product_variants
--    3. Logistics           : warehouses, inventory, carriers, shipments
--    4. Sales               : coupons, orders, order_items, payments
--    5. Feedback            : reviews
-- =====================================================================

DROP SCHEMA IF EXISTS shop CASCADE;
CREATE SCHEMA shop;
SET search_path TO shop;

-- ---------------------------------------------------------------------
-- 1. PLACES & PEOPLE
-- ---------------------------------------------------------------------
CREATE TABLE provinces (
    province_id   SMALLINT     PRIMARY KEY,
    name          VARCHAR(50)  NOT NULL UNIQUE,
    region        VARCHAR(10)  NOT NULL                              -- North / Central / South
);
COMMENT ON TABLE provinces IS 'Provinces and cities of Vietnam. Reference data, rarely changes.';

CREATE TABLE employees (
    employee_id   INTEGER      PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    department    VARCHAR(30)  NOT NULL,
    manager_id    INTEGER      REFERENCES employees(employee_id),   -- self-reference: org chart
    hire_date     DATE         NOT NULL,
    salary        NUMERIC(12,0) NOT NULL CHECK (salary > 0)          -- VND per month
);
COMMENT ON COLUMN employees.manager_id IS 'NULL = head of the company. Used for self-joins and recursive CTEs.';

CREATE TABLE customers (
    customer_id   INTEGER      PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(120) NOT NULL UNIQUE,
    phone         VARCHAR(15),                                        -- nullable (not provided)
    gender        CHAR(1)      CHECK (gender IN ('M', 'F')),          -- nullable
    birth_date    DATE,                                               -- nullable
    signup_date   DATE         NOT NULL,
    referred_by   INTEGER      REFERENCES customers(customer_id)      -- referring customer (self-reference)
);

CREATE TABLE addresses (
    address_id    INTEGER      PRIMARY KEY,
    customer_id   INTEGER      NOT NULL REFERENCES customers(customer_id),
    province_id   SMALLINT     NOT NULL REFERENCES provinces(province_id),
    street        VARCHAR(200) NOT NULL,
    is_default    BOOLEAN      NOT NULL DEFAULT FALSE
);
-- At most one default address per customer: a partial unique index
CREATE UNIQUE INDEX uq_addresses_one_default ON addresses(customer_id) WHERE is_default;

-- ---------------------------------------------------------------------
-- 2. SELLERS & CATALOG
-- ---------------------------------------------------------------------
CREATE TABLE sellers (
    seller_id          INTEGER      PRIMARY KEY,
    shop_name          VARCHAR(100) NOT NULL UNIQUE,
    province_id        SMALLINT     NOT NULL REFERENCES provinces(province_id),
    account_manager_id INTEGER      REFERENCES employees(employee_id),
    is_official        BOOLEAN      NOT NULL DEFAULT FALSE,           -- "official brand store"
    joined_date        DATE         NOT NULL
);

CREATE TABLE categories (
    category_id   INTEGER      PRIMARY KEY,
    name          VARCHAR(80)  NOT NULL,
    parent_id     INTEGER      REFERENCES categories(category_id)     -- multi-level category tree
);

CREATE TABLE products (
    product_id    INTEGER      PRIMARY KEY,
    seller_id     INTEGER      NOT NULL REFERENCES sellers(seller_id),
    category_id   INTEGER      NOT NULL REFERENCES categories(category_id),
    name          VARCHAR(150) NOT NULL,
    brand         VARCHAR(50),                                        -- nullable (unbranded goods)
    created_at    DATE         NOT NULL,
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE product_variants (
    variant_id    INTEGER      PRIMARY KEY,
    product_id    INTEGER      NOT NULL REFERENCES products(product_id),
    sku           VARCHAR(30)  NOT NULL UNIQUE,
    variant_name  VARCHAR(60)  NOT NULL,                              -- e.g. "Black", "Size M"
    price         NUMERIC(12,0) NOT NULL CHECK (price > 0),           -- CURRENT selling price (VND)
    cost          NUMERIC(12,0) NOT NULL CHECK (cost > 0)             -- unit cost (VND)
);

-- ---------------------------------------------------------------------
-- 3. LOGISTICS
-- ---------------------------------------------------------------------
CREATE TABLE warehouses (
    warehouse_id  SMALLINT     PRIMARY KEY,
    name          VARCHAR(60)  NOT NULL UNIQUE,
    province_id   SMALLINT     NOT NULL REFERENCES provinces(province_id)
);

CREATE TABLE inventory (
    warehouse_id  SMALLINT     NOT NULL REFERENCES warehouses(warehouse_id),
    variant_id    INTEGER      NOT NULL REFERENCES product_variants(variant_id),
    quantity      INTEGER      NOT NULL CHECK (quantity >= 0),
    PRIMARY KEY (warehouse_id, variant_id)                            -- composite key: many-to-many table
);

CREATE TABLE carriers (
    carrier_id    SMALLINT     PRIMARY KEY,
    name          VARCHAR(60)  NOT NULL UNIQUE
);

-- ---------------------------------------------------------------------
-- 4. SALES
-- ---------------------------------------------------------------------
CREATE TABLE coupons (
    coupon_id       INTEGER      PRIMARY KEY,
    code            VARCHAR(30)  NOT NULL UNIQUE,
    discount_type   VARCHAR(10)  NOT NULL CHECK (discount_type IN ('percent', 'fixed')),
    discount_value  NUMERIC(12,0) NOT NULL CHECK (discount_value > 0),  -- percent, or an amount in VND
    min_order_value NUMERIC(12,0) NOT NULL DEFAULT 0,
    valid_from      DATE         NOT NULL,
    valid_to        DATE         NOT NULL,
    CHECK (valid_to >= valid_from),
    CHECK (discount_type <> 'percent' OR discount_value <= 100)
);

CREATE TABLE orders (
    order_id      INTEGER      PRIMARY KEY,
    customer_id   INTEGER      NOT NULL REFERENCES customers(customer_id),
    address_id    INTEGER      NOT NULL REFERENCES addresses(address_id),
    coupon_id     INTEGER      REFERENCES coupons(coupon_id),         -- NULL = no coupon used
    order_date    TIMESTAMP    NOT NULL,
    status        VARCHAR(12)  NOT NULL CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled', 'returned'))
);
COMMENT ON TABLE orders IS 'No total column: total = SUM(order_items.quantity * unit_price) - discount + shipping fee (3NF).';

CREATE TABLE order_items (
    order_id      INTEGER      NOT NULL REFERENCES orders(order_id),
    variant_id    INTEGER      NOT NULL REFERENCES product_variants(variant_id),
    quantity      SMALLINT     NOT NULL CHECK (quantity > 0),
    unit_price    NUMERIC(12,0) NOT NULL CHECK (unit_price > 0),      -- price AT PURCHASE TIME (not the current price)
    PRIMARY KEY (order_id, variant_id)
);
COMMENT ON COLUMN order_items.unit_price IS 'Stored because prices change over time — this is NOT redundant data.';

CREATE TABLE payments (
    payment_id    INTEGER      PRIMARY KEY,
    order_id      INTEGER      NOT NULL REFERENCES orders(order_id),
    method        VARCHAR(15)  NOT NULL CHECK (method IN ('cod', 'card', 'ewallet', 'bank_transfer')),
    amount        NUMERIC(12,0) NOT NULL CHECK (amount > 0),
    status        VARCHAR(10)  NOT NULL CHECK (status IN ('success', 'failed', 'refunded')),
    paid_at       TIMESTAMP    NOT NULL
);

CREATE TABLE shipments (
    shipment_id   INTEGER      PRIMARY KEY,
    order_id      INTEGER      NOT NULL UNIQUE REFERENCES orders(order_id),  -- one-to-one with orders
    carrier_id    SMALLINT     NOT NULL REFERENCES carriers(carrier_id),
    warehouse_id  SMALLINT     NOT NULL REFERENCES warehouses(warehouse_id),
    shipping_fee  NUMERIC(12,0) NOT NULL CHECK (shipping_fee >= 0),
    shipped_at    TIMESTAMP    NOT NULL,
    delivered_at  TIMESTAMP,                                          -- NULL = still in transit
    CHECK (delivered_at IS NULL OR delivered_at >= shipped_at)
);

-- ---------------------------------------------------------------------
-- 5. FEEDBACK
-- ---------------------------------------------------------------------
CREATE TABLE reviews (
    review_id     INTEGER      PRIMARY KEY,
    customer_id   INTEGER      NOT NULL REFERENCES customers(customer_id),
    product_id    INTEGER      NOT NULL REFERENCES products(product_id),
    rating        SMALLINT     NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment       TEXT,                                               -- nullable (stars only)
    created_at    TIMESTAMP    NOT NULL,
    UNIQUE (customer_id, product_id)
);

-- ---------------------------------------------------------------------
-- INDEXES: only PRIMARY KEY / UNIQUE columns are indexed automatically.
-- The foreign keys below are INTENTIONALLY left unindexed — Chapter 17 measures and creates them.
-- ---------------------------------------------------------------------
-- CREATE INDEX idx_orders_customer   ON orders(customer_id);
-- CREATE INDEX idx_order_items_variant ON order_items(variant_id);
-- CREATE INDEX idx_orders_order_date ON orders(order_date);

-- Learners use a read-only account for exercises (see 03-roles.sql)
