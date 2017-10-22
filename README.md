# test-postgresql-sqitch [![Build Status](https://travis-ci.org/kwakwaversal/test-postgresql-sqitch.svg?branch=master)](https://travis-ci.org/kwakwaversal/test-postgresql-sqitch)
Test PostgreSQL features to make sure they do what's expected

# Description
Over time there have been PostgreSQL-specific features I've wanted to check.
The first one was to make sure [citext] was doing what I expect it to do. I will
expand on these when and as I feel necessary.

N.B., I am using [Sqitch] for testing.

# Tests

## [citext]
The [citext] module provides a case-insensitive character string type, `citext`.
Essentially, it internally calls `lower()` when comparing values. Otherwise, it
behaves almost exactly like `text`.

The tests make sure it does this, and that an index is used appropriately.

# Using Sqitch
This repository is also an excuse for me to use [Sqitch]. Sqitch is a database
change management application. The `verify` feature makes it particularly useful
when combined with [Github] and [Travis].

N.B., It is *not* best practice to use [Sqitch] in this way because the `verify`
command should contain tests without any regard for data.

## Commands
Initialise a new project.

```
sqitch init testing --uri https://github.com/kwakwaversal/test-postgresql-sqitch --engine pg
```

Tell [Sqitch] who we are (used for the plan's audit trail). The `--user` flag
means that this particular config will be written to the executing user's
`~/.sqitch/sqitch.conf` file.

```
sqitch config --user user.name 'Paul Williams'
sqitch config --user user.email 'kwakwaversal@...'
```

Add a new database *change*.

```
sqitch add extensions -n 'Add Pg extensions (CITEXT)'
sqitch add citext --requires extension -n 'Add CITEXT test'
```

# References
* [Sqitch turorial](https://metacpan.org/pod/distribution/App-Sqitch/lib/sqitchtutorial.pod)

[citext]: https://www.postgresql.org/docs/current/static/citext.html
[Github]: https://github.com/
[Sqitch]: http://sqitch.org/
[Travis]: https://travis-ci.org/
