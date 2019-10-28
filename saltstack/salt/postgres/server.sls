postgres-server:
  pkg.installed:
    - install_recommends: False
    - names:
      - postgresql
      - postgresql-contrib
      - pgtap

postgres-server-running:
  service.running:
    - name: postgresql
    - enable: true
