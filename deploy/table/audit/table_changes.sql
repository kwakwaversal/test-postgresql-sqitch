-- Deploy testing:table/audit/table_changes to pg
-- requires: schema/audit

BEGIN;

CREATE TABLE audit.table_changes (
  id uuid default public.gen_random_uuid() not null,
  added timestamp with time zone default CURRENT_TIMESTAMP not null,
  added_by text,
  schema_name text not null default 'public',
  table_name text not null,
  column_name text not null,
  pk_name text default 'id' not null,
  pk_value text not null,
  old_value text,
  new_value text
);

COMMENT ON TABLE audit.table_changes IS
'Track all table column changes (updates only)';

COMMENT ON COLUMN audit.table_changes.table_name IS
'Schema name the table belongs to';

COMMENT ON COLUMN audit.table_changes.table_name IS
'Table name the column update belongs to';

COMMENT ON COLUMN audit.table_changes.column_name IS
'Name of the column that changed';

COMMIT;
