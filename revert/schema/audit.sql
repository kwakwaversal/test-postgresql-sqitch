-- Revert testing:schema/audit from pg

BEGIN;

DROP SCHEMA audit;

COMMIT;
