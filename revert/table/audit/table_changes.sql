-- Revert testing:table/audit/table_changes from pg

BEGIN;

DROP TABLE audit.table_changes;

COMMIT;
