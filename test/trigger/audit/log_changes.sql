BEGIN;

/* SELECT plan(1); */
SELECT no_plan();

/****************************************************************************/
-- Uncomment to make it easier testing functions without sqitch rebasing

/* \i deploy/trigger/audit/log_changes.sql */

/*****************************************************************************/
-- Reusable prepared statements

PREPARE audit_count AS
  SELECT is(count(*)::integer, $1, $2)
    FROM audit.table_changes;

PREPARE reset_audit_changes AS
  DELETE FROM audit.table_changes;

/*****************************************************************************/
-- Basic test

CREATE TEMPORARY TABLE basic (
  id uuid default public.gen_random_uuid() not null,
  name text,
  num integer,
  added_at timestamp with time zone default CURRENT_TIMESTAMP,
  added_by uuid
);

CREATE TRIGGER basic_trigger
  AFTER UPDATE ON basic
    FOR EACH ROW
    EXECUTE PROCEDURE audit.log_changes();

INSERT INTO basic(name) VALUES('hello');
EXECUTE audit_count(0, 'insert does not create table_changes');

UPDATE basic SET name='bar', added_at=NOW()+'1 second'::interval, num=10;
EXECUTE audit_count(3, '3 changes added from update');

EXECUTE reset_audit_changes;

/*****************************************************************************/
-- Column exlusion test using regex

CREATE TEMPORARY TABLE exclusion (
  id serial not null,
  name text,
  added_at timestamp with time zone default CURRENT_TIMESTAMP,
  added_by uuid
);

CREATE TRIGGER exclusion_trigger
  AFTER UPDATE ON exclusion
    FOR EACH ROW
    EXECUTE PROCEDURE audit.log_changes('{"exclude": "^added_at$"}');

INSERT INTO exclusion(name) VALUES('hello');
UPDATE exclusion SET name='bar', added_at=NOW()+'1 second'::interval;
EXECUTE audit_count(1, '2 changes added from update');

EXECUTE reset_audit_changes;

/*****************************************************************************/
-- If exists, use a column that identifies the person who did the update

CREATE TEMPORARY TABLE addedby (
  id serial not null,
  name text,
  added_at timestamp with time zone default CURRENT_TIMESTAMP,
  added_by text,
  updated_at timestamp with time zone default CURRENT_TIMESTAMP,
  updated_by text
);

CREATE TRIGGER addedby_trigger
  AFTER UPDATE ON addedby
    FOR EACH ROW
    EXECUTE PROCEDURE audit.log_changes('{"updated_by": "updated_by"}');

INSERT INTO addedby(name) VALUES('hello');
UPDATE addedby SET name='bar', updated_at=NOW()+'1 second', updated_by='eric';
SELECT is(count(*)::integer, 3, 'eric is the owner of 3 updates')
  FROM audit.table_changes WHERE added_by = 'eric';

EXECUTE reset_audit_changes;

/*****************************************************************************/
-- Debugging

SELECT * FROM audit.table_changes;

/*****************************************************************************/
-- Finish and tear down

SELECT * FROM finish();

ROLLBACK;
