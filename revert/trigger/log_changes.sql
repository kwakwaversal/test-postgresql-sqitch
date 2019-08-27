-- Revert testing:trigger/log_changes from pg

BEGIN;

DROP FUNCTION audit.log_changes();

COMMIT;
