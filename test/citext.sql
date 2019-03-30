SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;

SELECT plan(1);

SELECT has_table('ciemails');

SELECT finish();

ROLLBACK;
