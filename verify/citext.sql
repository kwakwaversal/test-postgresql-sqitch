-- Verify testing:citext on pg

BEGIN;

INSERT INTO ciemails (name, email) VALUES
    ('Paul', 'MY@email.com'),
    ('David', 'his@EMAIL.com');

-- can search CITEXT column with any case
SELECT 1/COUNT(*) FROM ciemails WHERE email='my@email.com';
-- can search CITEXT column with any case
SELECT 1/COUNT(*) FROM ciemails WHERE email='HIS@EMAIL.com';
-- the returned CITEXT value is the same as what was inserted
SELECT 1/COUNT(*)
    WHERE 'his@EMAIL.com'::TEXT IN (SELECT email FROM ciemails WHERE email='HIS@EMAIL.com');

-- check the output of EXPLAIN to see if an index scan is used
SELECT 1/COUNT(*)
    FROM util_explain_query($$SELECT name FROM ciemails WHERE email='my@email.com'$$) AS output
    WHERE output LIKE '%Index Scan%';

DELETE FROM ciemails;

ROLLBACK;
