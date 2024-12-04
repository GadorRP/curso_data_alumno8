{% macro obtener_valores(table, column) %}
 
  {% set query_sql %}
    SELECT DISTINCT {{column}} FROM {{table}}
    {% endset %}
    
    {% set results = run_query(query_sql) %}
    
    {% if execute %}
        {% set results_list = results.columns[0].values() %}
    {% else %}
        {% set results_list = [] %}
    {% endif %}

{{ return(results_list) }}
{% endmacro %}