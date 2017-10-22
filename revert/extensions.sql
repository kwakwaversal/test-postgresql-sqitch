-- Revert testing:extensions from pg

BEGIN;

DROP EXTENSION CITEXT;

COMMIT;
