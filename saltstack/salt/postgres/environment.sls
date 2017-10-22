postgres-env-pg-service:
  file.managed:
    - name: /home/vagrant/.pg_service.conf
    - source: salt://postgres/files/.pg_service.conf
    - user: vagrant
    - group: vagrant
    - mode: 644
