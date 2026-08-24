-- Dimension table for patients with incremental merge on patient_id
-- Co-authored with CoCo
{{
  config(
    unique_key = 'patient_id',
    incremental_strategy = 'merge',
    on_schema_change = 'append_new_columns'
  )
}}

with staged as (
    select * from {{ source('stg', 'stg_patients') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
),

final as (
    select
        patient_id,
        first_name,
        last_name,
        first_name || ' ' || last_name as full_name,
        date_of_birth,
        datediff('year', date_of_birth, current_date()) as age,
        gender,
        email,
        phone,
        address,
        city,
        state,
        zip_code,
        insurance_provider,
        created_at,
        updated_at,
        current_timestamp() as dbt_updated_at
    from staged
)

select * from final
