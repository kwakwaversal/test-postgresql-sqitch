-- Deploy testing:utils to pg

BEGIN;

-- https://stackoverflow.com/questions/22101229/explain-analyze-within-pl-pgsql-gives-error-query-has-no-destination-for-resul
--
-- This util function provides a way of retrieving the output of EXPLAIN for a
-- dynamic query. This is particularly useful to make sure that an index scan is
-- being used when appropriate.
--
-- SELECT 1/COUNT(*)
--    FROM util_explain_query($$SELECT name FROM ciemails WHERE email='my@email.com'$$) AS output
--    WHERE output LIKE '%Index Scan%';
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
