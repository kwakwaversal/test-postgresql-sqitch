postgres-users-sqitch_user:
  postgres_user.present:
    - name: sqitch_user
    - encrypted: true
    - default_password: {{ pillar['postgres']['password'] }}
    - groups: sqitch_ro,sqitch_rw
    - require:
      - postgres_group: postgres-priv-sqitch-ro
      - postgres_group: postgres-priv-sqitch-rw

postgres-users-super_sqitch_user:
  postgres_user.present:
    - name: super_sqitch_user
    - encrypted: true
    - default_password: {{ pillar['postgres']['password'] }}
    - superuser: true
