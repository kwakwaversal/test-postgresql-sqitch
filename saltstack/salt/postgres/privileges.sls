# https://docs.saltstack.com/en/latest/ref/states/all/salt.states.postgres_privileges.html

# RO
#
# Privileges for doing read only stuff
postgres-priv-sqitch-ro:
  postgres_group.present:
    - name: sqitch_ro

# RW
#
# Privileges for doing read write stuff
postgres-priv-sqitch-rw:
  postgres_group.present:
    - name: sqitch_rw
