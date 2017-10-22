postgres-database:
  postgres_database.present:
    - name: sqitch
    - require:
      - sls: postgres.server
