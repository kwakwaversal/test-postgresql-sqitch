-- Revert testing:trigger/audit/log_changes from pg

BEGIN;

DROP FUNCTION audit.log_changes();

COMMIT;
