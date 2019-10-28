-- Verify testing:trigger/audit/log_changes on pg

BEGIN;

SELECT has_function_privilege('audit.log_changes()', 'execute');

ROLLBACK;
