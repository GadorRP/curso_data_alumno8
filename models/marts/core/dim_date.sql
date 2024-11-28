WITH stg_date as (
    SELECT
        *
    FROM {{ref('stg_date') }}
),

dim_date as (
    SELECT
        PRIOR_YEAR_ISO_WEEK_OF_YEAR
        , MONTH_OF_YEAR
        , MONTH_NAME
        , MONTH_NAME_SHORT
        , MONTH_START_DATE
        , MONTH_END_DATE
        , PRIOR_YEAR_MONTH_START_DATE
        , PRIOR_YEAR_MONTH_END_DATE
        , QUARTER_OF_YEAR
        , QUARTER_START_DATE
        , QUARTER_END_DATE
        , YEAR_NUMBER
        , YEAR_START_DATE
        , YEAR_END_DATE
    FROM stg_date
)

SELECT * FROM dim_date