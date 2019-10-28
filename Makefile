all: pg_prove

pg_prove:
	pg_prove -v -r test/ --ext .sql

.PHONY: all pg_prove
