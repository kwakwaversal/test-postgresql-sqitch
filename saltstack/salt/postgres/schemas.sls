{% for schema in ['test'] %}
postgres-schema-{{ schema }}:
  postgres_schema.present:
    - name: {{ schema }}
    - dbname: sqitch
    - require:
      - sls: postgres.databases
{% endfor %}
