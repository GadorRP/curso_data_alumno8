{%  macro replace_with(column_name, old_value, new_value, istext) %}
    {% if istext%}
        CASE WHEN {{ column_name}}  = '{{ old_value }}' THEN '{{ new_value }}'
            ELSE {{ column_name }} END
    {% else %}
        CASE WHEN {{ column_name}}  = {{ old_value }} THEN {{ new_value }}
            ELSE {{ column_name }} END
    {% endif %}
{% endmacro %}