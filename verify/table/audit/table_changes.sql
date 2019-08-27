-- Verify testing:table/audit/table_changes on pg

BEGIN;

SELECT * FROM audit.table_changes WHERE false;

ROLLBACK;
