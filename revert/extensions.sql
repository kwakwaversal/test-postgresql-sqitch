-- Revert testing:extensions from pg

BEGIN;

DROP EXTENSION CITEXT;

DROP EXTENSION PGCRYPTO;

COMMIT;
