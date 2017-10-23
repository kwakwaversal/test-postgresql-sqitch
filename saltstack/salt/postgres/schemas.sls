{% for schema in ['testing'] %}
postgres-schema-{{ schema }}:
  postgres_schema.present:
    - name: {{ schema }}
    - dbname: sqitch
    - require:
      - sls: postgres.databases
{% endfor %}
