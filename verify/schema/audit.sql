-- Verify testing:schema/audit on pg

BEGIN;

SELECT pg_catalog.has_schema_privilege('audit', 'usage');

ROLLBACK;
