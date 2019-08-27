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

BEGIN
  IF TG_OP = 'INSERT' THEN

  ELSIF TG_OP = 'UPDATE' THEN

  END IF;
END;
$BODY$ LANGUAGE plpgsql;


COMMIT;
