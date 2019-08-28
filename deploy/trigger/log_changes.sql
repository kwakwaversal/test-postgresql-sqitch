-- Deploy testing:trigger/log_changes to pg
-- requires: schema/audit

BEGIN;

CREATE OR REPLACE FUNCTION audit.log_changes()
  RETURNS trigger AS
$BODY$
-- Only *updates* to a table are tracked in `audit.table_changes`. This allows
-- rudimentary PITR (point in time recovery) to be performed on tables which
-- match a specific convention.
DECLARE
  col text;
  jsnew jsonb := to_jsonb(NEW);
  jsold jsonb := to_jsonb(OLD);
  pkcol text := 'id';
BEGIN
  IF TG_OP = 'UPDATE' THEN

    FOR col IN SELECT * FROM jsonb_object_keys(jsnew)
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
            user,
            TG_TABLE_SCHEMA,
            TG_TABLE_NAME,
            col,
            pkcol,
            jsnew->>pkcol,
            jsold->>col,
            jsnew->>col
          );
        RAISE NOTICE '%: %', col, jsnew->>col;
      END IF;
    END LOOP;

  END IF;

  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;

COMMIT;
