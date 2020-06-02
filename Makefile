all: test

deploy:
	sqitch deploy

rebase:
	sqitch rebase --onto extensions -y

revert:
	sqitch revert --to-change extensions -y

test:
	pg_prove -v -r test/ --ext .sql

.PHONY: all deploy rebase revert test
