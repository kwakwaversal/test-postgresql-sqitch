-- Verify testing:extensions on pg

BEGIN;

-- https://www.postgresql.org/docs/current/static/view-pg-available-extensions.html
SELECT
    1/COUNT(*)
FROM
    pg_available_extensions
WHERE
    name='citext';

-- https://www.postgresql.org/docs/current/static/catalog-pg-extension.html
SELECT
    1/COUNT(*)
FROM
    pg_extension
WHERE
    extname='citext';

ROLLBACK;
