-- Revert testing:utils from pg

BEGIN;

DROP FUNCTION util_explain_query(text);

COMMIT;
