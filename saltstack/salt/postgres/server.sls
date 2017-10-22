postgres-server:
  pkg.installed:
    - install_recommends: False
    - names:
      - postgresql

postgres-server-running:
  service.running:
    - name: postgresql
    - enable: true
