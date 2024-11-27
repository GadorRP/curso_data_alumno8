{% macro set_positive_values(column_name) %}
    CASE 
        WHEN {{ column_name }} IS NULL THEN 0 
        WHEN {{ column_name }} < 0 THEN ABS({{ column_name }})
        ELSE {{ column_name }} 
    END
{% endmacro %}