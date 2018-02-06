-- Revert testing:constraints from pg

BEGIN;

DROP TABLE companies;
DROP TABLE features;

COMMIT;
