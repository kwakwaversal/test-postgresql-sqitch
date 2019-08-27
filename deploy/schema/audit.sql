-- Deploy testing:schema/audit to pg

BEGIN;

CREATE SCHEMA audit;

COMMENT ON SCHEMA audit IS
'Namespace for audit-related tables and functions';


COMMIT;
