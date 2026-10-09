-- id: M05
-- title: Employees and their managers
-- chapter: 7
-- tags: SELF JOIN, LEFT JOIN, COALESCE
-- ordered: true
-- prompt: For every employee, show employee_id, full_name and manager (the name of their direct manager).
--   If an employee has no manager, show 'None'. Sort by employee_id.
-- hint: Treat employees as TWO different tables: one playing "employee", one playing "manager".
SELECT e.employee_id, e.full_name,
       COALESCE(m.full_name, 'None') AS manager
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id
ORDER BY e.employee_id;
