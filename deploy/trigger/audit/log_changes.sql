-- Deploy testing:trigger/audit/log_changes to pg
-- requires: schema/audit

BEGIN;

CREATE OR REPLACE FUNCTION audit.log_changes()
  RETURNS trigger AS
$BODY$
-- Only *updates* to a table are tracked in `audit.table_changes`. This allows
-- rudimentary PITR (point in time recovery) to be performed on tables which
-- match a specific convention.
--
-- N.B., this will not work for composite primary keys.
--
-- @param {jsonb} args - options
-- @param {text} [args.pk] - optional primary key to use (default: `id`)
-- @param {text} [args.exclude] - regular expression of columns to exclude.
-- e.g., '^added_(at|by)$' will not include the column `added_at` or
-- `added_by`. Useful for excluding columns that change all the time but aren't
-- important to the auditing log such as the `updated_at` column.
--
-- @example
-- CREATE TEMPORARY TABLE foo (
--   id uuid default public.gen_random_uuid() not null,
--   name text,
--   num integer,
--   added_at timestamp with time zone default CURRENT_TIMESTAMP,
--   added_by uuid
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
  jsnew jsonb := to_jsonb(NEW);
  jsold jsonb := to_jsonb(OLD);
  pkcol text := COALESCE(args->>'pk', 'id');
  upcol text := COALESCE(args->>'updated_by', 'updated_by');
BEGIN
  IF TG_OP = 'UPDATE' AND TG_LEVEL = 'ROW' THEN

    FOR col IN
      SELECT
        *
      FROM
        jsonb_object_keys(jsnew) key
      WHERE
        (args->>'exclude' IS NULL OR key !~ (args->>'exclude')::text)
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
            jsnew->>pkcol,
            jsold->>col,
            jsnew->>col
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
