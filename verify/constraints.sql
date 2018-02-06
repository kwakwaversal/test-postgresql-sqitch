-- Verify testing:constraints on pg

BEGIN;

INSERT INTO features VALUES(1, 'default');
INSERT INTO companies VALUES(1, 'kwakwa', 1);

-- check the constraint type is restricted
SELECT 1/COUNT(*)
  FROM pg_catalog.pg_constraint
 WHERE conname='companies_feature_id_fkey' AND confdeltype='r';

-- should raise constraint "companies_feature_id_fkey" which restricts on delete
SELECT 1/COUNT(*)
  FROM util_exception_query($$DELETE FROM features$$) AS output
 WHERE output ILIKE '%violates foreign key constraint%';

ROLLBACK;
