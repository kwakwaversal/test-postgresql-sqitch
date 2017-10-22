# test-postgresql-sqitch [![Build Status](https://travis-ci.org/kwakwaversal/test-postgresql-sqitch.svg?branch=master)](https://travis-ci.org/kwakwaversal/test-postgresql-sqitch)
Test PostgreSQL features to make sure they do what's expected

# Description
Over time there have been PostgreSQL-specific features I've wanted to check.
The first one was to make sure [citext] was doing what I expect it to do. I will
expand on these when and as I feel necessary.

N.B., I am using [sqitch] for testing.

# Tests

## [citext]
The citext module provides a case-insensitive character string type, citext.
Essentially, it internally calls lower when comparing values. Otherwise, it
behaves almost exactly like text.

The tests make sure it does this, and that an index is used appropriately.

# Using sqitch
This repository is also an excuse for me to use [sqitch]. Sqitch is a database
change management application. The `verify` feature makes it particularly useful
when combined with [github] and [travis].

## Commands
Initialise a new project.

```
sqitch init testing --uri https://github.com/kwakwaversal/test-postgresql-sqitch --engine pg
```

Tell sqitch who we are (used for auditing the plan).

```
sqitch config --user user.name 'Paul Williams'
sqitch config --user user.email 'kwakwaversal@...'
```

# References
* [Sqitch turorial](https://metacpan.org/pod/distribution/App-Sqitch/lib/sqitchtutorial.pod)

[citext]: https://www.postgresql.org/docs/current/static/citext.html
[github]: https://github.com/
[sqitch]: http://sqitch.org/
[travis]: https://travis-ci.org/
