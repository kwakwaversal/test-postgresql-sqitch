# Abstract
This documents basic instructions to test sqitch within the vagrant machine.

# Synopsis
These commands should be run from within a provisioned vagrant machine.

```bash
$ vagrant up
$ vagrant ssh
$ cd /vagrant
$ sqitch deploy --verify db:pg://super_sqitch_user:password@localhost/sqitch
$ sqitch verify db:pg://super_sqitch_user:password@localhost/sqitch
$ sqitch revert --to-change citext db:pg://super_sqitch_user:password@localhost/sqitch
```

```bash
# the following aliases have also been added to speed up testing
$ sd # sqitch deploy
$ sv # sqitch verify
$ sr # revert to the penultimate change in sqitch.plan
```

If you make any changes to the salt stack, you can apply them with:

```bash
sudo salt-call --local state.apply
```

# Aliases
The shell aliases above are as follows:

```bash
alias sd='sqitch deploy db:pg://super_sqitch_user:password@localhost/sqitch'
alias sv='sqitch verify db:pg://super_sqitch_user:password@localhost/sqitch'
# revert to the penultimate change
alias sr='sqitch revert --to-change $(tail sqitch.plan -n 2 | head -1 | awk '"'"'{print $1;}'"'"') db:pg://super_sqitch_user:password@localhost/sqitch'
```
