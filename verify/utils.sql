-- Verify testing:utils on pg

BEGIN;

SELECT has_function_privilege('util_explain_query(text)', 'execute');

ROLLBACK;
