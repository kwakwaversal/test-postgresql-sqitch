-- Deploy testing:trigger/audit/log_changes to pg
-- requires: schema/audit

BEGIN;

CREATE OR REPLACE FUNCTION audit.log_changes()
  RETURNS trigger AS
$BODY$
-- Only *updates* to a table are tracked in `audit.table_changes`. This allows
-- rudimentary PITR (point in time recovery) to be performed on tables.
--
-- For this to work, the table *can have* an `updated_at` column to extract the
-- change time (the name of the column can be overridden). If you set this
-- option to `null` it will assume there is no such column and default to
-- `CURRENT_TIMESTAMP`.
--
-- N.B., this will not work as expected if you change the value of the primary
-- key - you would have to work to figure out it changing from one PK to a new
-- PK.
--
-- @param {jsonb} args - options
-- @param {text} [args.exclude] - regular expression of columns to exclude.
-- e.g., '^added_(at|by)$' will not include the column `added_at` or
-- `added_by`. Useful for excluding columns that change all the time but aren't
-- important to the auditing log such as the `updated_at` column.
-- @param {text} [args.pk] - optional primary key to use (default: `ARRAY['id']`)
-- @param {text} [args.updated_by] - optional column name to extract the
-- "change" time from the record (default: `updated_at`)
--
-- @example
-- CREATE TEMPORARY TABLE foo (
--   id uuid default public.gen_random_uuid() not null,
--   name text,
--   num integer,
--   created_at timestamp with time zone default CURRENT_TIMESTAMP,
--   created_by uuid
-- );
--
-- CREATE TRIGGER foo_trigger
--   AFTER UPDATE ON foo
--     FOR EACH ROW
--     EXECUTE PROCEDURE audit.log_changes('{"exclude": "^added_at$"}');
--
DECLARE
  args jsonb := CASE
    WHEN TG_NARGS = 1 THEN TG_ARGV[0]::JSONB
  END;
  col text;
  colexclude text := CASE
    WHEN args#>'{exclude}' IS NOT NULL THEN args->>'exclude'
    ELSE '^(updated)_(at|by)$'
  END;
  jsnew jsonb := to_jsonb(NEW);
  jsold jsonb := to_jsonb(OLD);
  pkcol text [] := COALESCE(
    NULLIF(
      ARRAY(
        SELECT
          jsonb_array_elements_text(args->'pk')
      ),
      '{}'
    ),
    ARRAY['id']
  );
  pkval text[];
  upcol text := COALESCE(args->>'updated_by', 'updated_by');
BEGIN
  IF TG_OP = 'UPDATE' AND TG_LEVEL = 'ROW' THEN

    -- Get the primary key value. This function supports compound indexes and
    -- stores them as an array - so this builds up the `pkval` array.
    FOREACH col IN ARRAY pkcol
    LOOP
      IF (jsnew->col)::text IS NULL THEN
        RAISE EXCEPTION 'No primary key `%` found for `%.%` when inserting audit log', col, TG_TABLE_SCHEMA, TG_TABLE_NAME;
      END IF;

      pkval = pkval || (jsnew->col)::text;
    END LOOP;

    FOR col IN
      SELECT
        *
      FROM
        jsonb_object_keys(jsnew) key
      WHERE
        (colexclude IS NULL OR LOWER(key) !~ colexclude)
    LOOP
      IF jsnew->>col IS DISTINCT FROM jsold->>col THEN
        INSERT INTO
          audit.table_changes(
            added_by,
            schema_name,
            table_name,
            column_name,
            pk_name,
            pk_value,
            old_value,
            new_value
          )
        VALUES
          (
            COALESCE((jsnew->>upcol)::text, user::text),
            TG_TABLE_SCHEMA,
            TG_TABLE_NAME,
            col,
            pkcol,
            pkval,
            jsold->col,
            jsnew->col
          );
        /* RAISE NOTICE '%: %', col, jsnew->>col; */
        /* RAISE NOTICE '------ %', COALESCE(jsnew->>upcol, user); */
      END IF;
    END LOOP;

  END IF;

  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;

COMMIT;
