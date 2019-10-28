postgres-env-pg-service-root:
  file.managed:
    - name: /root/.pg_service.conf
    - source: salt://postgres/files/.pg_service.conf
    - user: vagrant
    - group: vagrant
    - mode: 644

postgres-env-pg-service-vagrant:
  file.managed:
    - name: /home/vagrant/.pg_service.conf
    - source: salt://postgres/files/.pg_service.conf
    - user: vagrant
    - group: vagrant
    - mode: 644

postgres-install-pgtap-extension:
  cmd.run:
    - unless: PGSERVICE=sqitch psql -c '\dx' | grep pgtap >> /dev/null
    - name: PGSERVICE=sqitch psql -c 'create extension pgtap;'
