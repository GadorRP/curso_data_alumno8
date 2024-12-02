{% test date_before(model, column_name, column_after) %}

   select *
   from {{ model }}
   where TIMESTAMPDIFF(MINUTE,{{column_after}}, {{column_name}})  > 0 --menor que 0 es que ocurrio la primera coluna ocurrio despues
   
{% endtest %}
