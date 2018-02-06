-- Deploy testing:utils to pg

BEGIN;

-- https://www.postgresql.org/docs/current/static/plpgsql-control-structures.html#PLPGSQL-ERROR-TRAPPING
--
-- This util function provides a way of retrieving the exception message of a
-- dynamic query. This is particularly useful for making sure exceptions are
-- raised for queries with strict constraints.
--
-- SELECT 1/COUNT(*)
--   FROM util_exception_query($$DELETE FROM features$$) AS output
--  WHERE output LIKE '%Index Scan%';
--
CREATE OR REPLACE FUNCTION util_exception_query(text)
  RETURNS SETOF text AS
$func$
DECLARE
    text_msg text;
    text_detail text;
    text_hint text;
BEGIN
    EXECUTE $1;
EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS text_msg    = MESSAGE_TEXT,
                            text_detail = PG_EXCEPTION_DETAIL,
                            text_hint   = PG_EXCEPTION_HINT;
    RETURN NEXT text_msg;
END
$func$ LANGUAGE plpgsql;

-- https://stackoverflow.com/questions/22101229/explain-analyze-within-pl-pgsql-gives-error-query-has-no-destination-for-resul
--
-- This util function provides a way of retrieving the output of EXPLAIN for a
-- dynamic query. This is particularly useful to make sure that an index scan is
-- being used when appropriate.
--
-- SELECT 1/COUNT(*)
--   FROM util_explain_query($$SELECT name FROM ciemails WHERE email='my@email.com'$$) AS output
--  WHERE output LIKE '%Index Scan%';
--
CREATE OR REPLACE FUNCTION util_explain_query(text)
  RETURNS SETOF text AS
$func$
BEGIN
    RETURN QUERY
        EXECUTE 'EXPLAIN ANALYZE ' || $1;
END
$func$ LANGUAGE plpgsql;

COMMIT;
