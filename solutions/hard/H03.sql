-- id: H03
-- title: Org chart paths
-- chapter: 12
-- tags: RECURSIVE CTE, paths
-- ordered: true
-- prompt: For every employee, show employee_id, level (the head of the company = 1, their direct reports = 2, ...)
--   and path: the names from the head of the company down to the employee, joined with ' > '. Sort by employee_id.
WITH RECURSIVE tree AS (
    SELECT employee_id, 1 AS level, full_name::text AS path
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, t.level + 1, t.path || ' > ' || e.full_name
    FROM employees e
    JOIN tree t ON e.manager_id = t.employee_id
)
SELECT employee_id, level, path
FROM tree
ORDER BY employee_id;
