-- id: E10
-- title: Well-paid customer service staff
-- chapter: 3
-- tags: WHERE, AND
-- ordered: true
-- prompt: List full_name and salary of employees in the 'Customer Service' department earning more than 15,000,000.
--   Sort by salary descending, then full_name.
SELECT full_name, salary
FROM employees
WHERE department = 'Customer Service'
  AND salary > 15000000
ORDER BY salary DESC, full_name;
