{#
  WHERE YOUR TABLES GO. Everyone shares two schemas, so your name goes on the TABLE:

      DBT_LABS_DB.STAGING.SMITH_JOHN__STG_ORDERS
      DBT_LABS_DB.MODELED.SMITH_JOHN__DIM_CUSTOMERS

  The name comes from `schema:` in your profiles.yml. dbt uses these two macros for
  every table it builds AND every ref(), so you still just write ref('stg_orders').
#}

{# Schema: the folder's schema from dbt_project.yml (staging / modeled), as-is. #}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}

{# Table name: <your profile's schema>__<model name>, e.g. smith_john__stg_orders #}
{% macro generate_alias_name(custom_alias_name=none, node=none) -%}
    {{ target.schema }}__{{ custom_alias_name or node.name }}
{%- endmacro %}
