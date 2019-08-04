BEGIN;

SELECT plan(1);
--SELECT * from no_plan();

SELECT ok(true);

ROLLBACK;
