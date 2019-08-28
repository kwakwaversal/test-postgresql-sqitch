BEGIN;

/* SELECT plan(1); */
SELECT * FROM no_plan();

/*****************************************************************************/
-- Basic test

CREATE TEMPORARY TABLE foo (
  id uuid default public.gen_random_uuid() not null,
  name text,
  num integer,
  added timestamp with time zone default CURRENT_TIMESTAMP
);

CREATE TRIGGER foo_trigger
  AFTER UPDATE ON foo
    FOR EACH ROW
    EXECUTE PROCEDURE audit.log_changes();

INSERT INTO foo(name) VALUES('hello');

SELECT is(count(*)::integer, 0, 'insert does not create table_changes')
  FROM audit.table_changes WHERE table_name='foo';

UPDATE foo SET name='bar', added=NOW()+'1 second'::interval, num=10;

SELECT is(count(*)::integer, 3, '3 changes added from update')
  FROM audit.table_changes WHERE table_name='foo';

SELECT * FROM audit.table_changes;

/*****************************************************************************/
-- Finish and tear down

SELECT * FROM finish();

ROLLBACK;
