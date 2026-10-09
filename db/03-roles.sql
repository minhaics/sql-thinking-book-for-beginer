-- READ-ONLY account for learners and the exercise checker.
-- Practising with this account means you cannot accidentally delete data.
CREATE ROLE learner LOGIN PASSWORD 'learner';
GRANT CONNECT ON DATABASE chonhata TO learner;
GRANT USAGE ON SCHEMA shop TO learner;
GRANT SELECT ON ALL TABLES IN SCHEMA shop TO learner;
ALTER ROLE learner SET search_path TO shop;
ALTER ROLE learner SET statement_timeout = '15s';

-- The owner account (sqlbook) also uses the shop schema by default
ALTER ROLE sqlbook SET search_path TO shop;
