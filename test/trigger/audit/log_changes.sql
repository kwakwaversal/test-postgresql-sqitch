BEGIN;

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
  id serial,
  name text,
  num integer,
  created_at timestamp with time zone default CURRENT_TIMESTAMP
);

CREATE TRIGGER basic_trigger
  AFTER UPDATE ON basic
    FOR EACH ROW
    EXECUTE PROCEDURE audit.log_changes();

INSERT INTO basic(name) VALUES('hello');
EXECUTE audit_count(0, 'inserts do not create table_changes records');

UPDATE
  basic
SET
  name = 'bar',
  num = 10,
  -- Slightly contrived test - you shouldn't really be changing the create_at
  -- or created_by but this would be logged as it is useful.
  created_at = NOW() + '1 second' :: interval;
EXECUTE audit_count(3, '3 changes added from update (name, num, created_at)');

EXECUTE reset_audit_changes;

/*****************************************************************************/
-- Can override default `exclude` of `^updated_(at|by)$`

CREATE TEMPORARY TABLE overrideexclude (
  id serial not null,
  name text,
  updated_at timestamp with time zone default CURRENT_TIMESTAMP,
  updated_by text
);

CREATE TRIGGER overrideexclude_trigger
  AFTER UPDATE ON overrideexclude
    FOR EACH ROW
    EXECUTE PROCEDURE audit.log_changes('{"exclude": null}');

INSERT INTO overrideexclude(name) VALUES('hello');
UPDATE overrideexclude SET name = 'foo', updated_by = 'you';
SELECT is(count(*)::integer, 2, 'can disable exclude (name, updated_at)')
  FROM audit.table_changes;

EXECUTE reset_audit_changes;

/*****************************************************************************/
-- Column exlusion test using regex

CREATE TEMPORARY TABLE exclusion (
  id serial not null,
  name text,
  foo text
);

CREATE TRIGGER exclusion_trigger
  AFTER UPDATE ON exclusion
    FOR EACH ROW
    EXECUTE PROCEDURE audit.log_changes('{"exclude": "^foo$"}');

INSERT INTO exclusion(name) VALUES('hello');
UPDATE exclusion SET name='bar', foo='bar';
EXECUTE audit_count(1, '1 change added from update');

EXECUTE reset_audit_changes;

/*****************************************************************************/
-- If exists, use a column that identifies the person who did the update

CREATE TEMPORARY TABLE addedby (
  id serial not null,
  name text,
  added_at timestamp with time zone default CURRENT_TIMESTAMP,
  added_by text,
  updated_at timestamp with time zone default CURRENT_TIMESTAMP,
  updated_by_is_different text
);

CREATE TRIGGER addedby_trigger
  AFTER UPDATE ON addedby
    FOR EACH ROW
    EXECUTE PROCEDURE audit.log_changes('{"updated_by": "updated_by_is_different"}');

INSERT INTO addedby(name) VALUES('hello');
UPDATE
  addedby
SET
  name = 'bar',
  updated_at = NOW() + '1 second',
  updated_by_is_different = 'eric';
SELECT is(count(*)::integer, 2, 'eric is the owner of 2 updates (name, updated_by_is_different)')
  FROM audit.table_changes WHERE added_by = 'eric';

EXECUTE reset_audit_changes;

/*****************************************************************************/
-- Multicolumn compound index

CREATE TEMPORARY TABLE compoundidx (
  id_a integer not null,
  id_b integer not null,
  name text
);

-- Multiple primary keys (or primary keys that are not `id`) require the
-- trigger argument to explicitly list them.
CREATE TRIGGER compoundidx_trigger
  AFTER UPDATE ON compoundidx
    FOR EACH ROW
    EXECUTE PROCEDURE audit.log_changes('{"pk": ["id_a", "id_b"]}');

INSERT INTO compoundidx(id_a, id_b, name) VALUES(1, 2, 'hello');

UPDATE compoundidx SET name='bar';
EXECUTE audit_count(1, '1 change for compound index');

SELECT is(count(*)::integer, 1)
  FROM audit.table_changes WHERE pk_value = ARRAY['1', '2'];

EXECUTE reset_audit_changes;

/*****************************************************************************/
-- Complex data types

CREATE TEMPORARY TABLE complex (
  id serial,
  name text,
  num integer,
  textarray text[]
);

CREATE TRIGGER complex_trigger
  AFTER UPDATE ON complex
    FOR EACH ROW
    EXECUTE PROCEDURE audit.log_changes();

INSERT INTO complex(name) VALUES('hello');
UPDATE
  complex
SET
  textarray = ARRAY['1', '2'];

select ARRAY(SELECT jsonb_array_elements_text(new_value)) from audit.table_changes;

EXECUTE audit_count(1, '1 changes added from update (name, num, created_at)');

EXECUTE reset_audit_changes;

/*****************************************************************************/
-- Debugging

SELECT * FROM audit.table_changes;

/*****************************************************************************/
-- Finish and tear down

SELECT * FROM finish();

ROLLBACK;
