-- Verify testing:trigger/log_changes on pg

BEGIN;

SELECT has_function_privilege('audit.log_changes()', 'execute');

ROLLBACK;
