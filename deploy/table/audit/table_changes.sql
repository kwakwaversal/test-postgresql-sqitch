-- Deploy testing:table/audit/table_changes to pg
-- requires: schema/audit

BEGIN;

CREATE EXTENSION IF NOT EXISTS btree_gin;

CREATE TABLE audit.table_changes (
  id bigint GENERATED ALWAYS AS IDENTITY,
  added timestamp with time zone default CURRENT_TIMESTAMP not null,
  added_by text,
  schema_name text not null default 'public',
  table_name text not null,
  column_name text not null,
  pk_name text[] default array['id'] not null,
  pk_value text[] not null,
  old_value text,
  new_value text
);

CREATE INDEX table_changes_schema_name_to_pk_value_idx ON audit.table_changes
  USING gin (schema_name, table_name, pk_value);

COMMENT ON TABLE audit.table_changes IS
'Track all table column changes (updates only).';

COMMENT ON COLUMN audit.table_changes.added IS
'When the table change was tracked.';

COMMENT ON COLUMN audit.table_changes.added_by IS
'Who made the change (if it can be worked out from the record).';

COMMENT ON COLUMN audit.table_changes.schema_name IS
'Schema name the table belongs to.';

COMMENT ON COLUMN audit.table_changes.table_name IS
'Table name the column update belongs to.';

COMMENT ON COLUMN audit.table_changes.column_name IS
'Name of the column that changed.';

COMMENT ON COLUMN audit.table_changes.pk_name IS
'Primary key name from the tracked table. Used for PITR to rebuild a record.';

COMMENT ON COLUMN audit.table_changes.pk_value IS
'Primary key value from the tracked table. Used for PITR to rebuild a record.';

COMMIT;
