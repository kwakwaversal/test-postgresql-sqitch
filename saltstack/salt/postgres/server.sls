postgres-server:
  pkg.installed:
    - install_recommends: False
    - names:
      - postgresql
      - postgresql-contrib

postgres-server-running:
  service.running:
    - name: postgresql
    - enable: true
