# Name
This documents basic instructions to test sqitch within the vagrant machine.

# Synopsis
These commands should be run from within vagrant.

```bash
$ vagrant up
$ vagrant ssh
$ cd /vagrant
$ sqitch deploy db:pg://super_sqitch_user:password@localhost/sqitch
$ sqitch verify db:pg://super_sqitch_user:password@localhost/sqitch
$ sqitch revert --to-change citext db:pg://super_sqitch_user:password@localhost/sqitch
```

```bash
# the following aliases have also been added to speed up testing
$ sd # sqitch deploy
$ sv # sqitch verify
$ sr # revert to the penultimate change in sqitch.plan
```
