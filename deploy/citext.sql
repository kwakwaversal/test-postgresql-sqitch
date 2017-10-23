-- Deploy testing:citext to pg
-- requires: extensions
-- requires: utils

BEGIN;

CREATE TABLE ciemails (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email CITEXT NOT NULL
);

CREATE INDEX idx_ciemails_email ON ciemails USING btree (email);

COMMIT;
