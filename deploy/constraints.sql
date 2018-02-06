-- Deploy testing:constraints to pg

BEGIN;

CREATE TABLE features (
    feature_id integer PRIMARY KEY,
    name text
);

CREATE TABLE companies (
    company_id integer PRIMARY KEY,
    name text,
    feature_id integer REFERENCES features ON UPDATE CASCADE ON DELETE RESTRICT
);

COMMIT;
