-- H02 · Revenue rolled up to top-level categories (Hard)
-- Categories form a tree (parent_id). Products are attached only to leaf categories. Roll merchandise revenue
-- ('delivered' orders) up to every TOP-LEVEL category (parent_id IS NULL), including top-level categories with no
-- revenue (show 0). Return top_category and revenue, sorted by revenue descending, then top_category.

-- (write your query below)
