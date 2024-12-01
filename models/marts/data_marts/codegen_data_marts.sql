{% set excluded_models = ['codegen_data_marts','data_marts'] %}
{% set models_to_generate = codegen.get_models(directory='marts/data_marts') | reject('in', excluded_models) %}
{{ codegen.generate_model_yaml(
    model_names = models_to_generate
) }}