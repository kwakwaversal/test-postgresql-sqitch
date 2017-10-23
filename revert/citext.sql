-- Revert testing:citext from pg

BEGIN;

DROP TABLE IF EXISTS ciemails;

COMMIT;
