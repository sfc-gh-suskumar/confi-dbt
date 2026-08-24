-- Fact table for encounters with incremental merge on encounter_id
-- Co-authored with CoCo
{{
  config(
    unique_key = 'encounter_id',
    incremental_strategy = 'merge',
    on_schema_change = 'append_new_columns'
  )
}}

with staged as (
    select * from {{ source('stg', 'stg_encounters') }}
    {% if is_incremental() %}
    where updated_at > (select max(updated_at) from {{ this }})
    {% endif %}
),

final as (
    select
        encounter_id,
        patient_id,
        provider_id,
        encounter_date,
        encounter_type,
        chief_complaint,
        discharge_date,
        discharge_disposition,
        total_charges,
        facility,
        length_of_stay_days,
        created_at,
        updated_at,
        current_timestamp() as dbt_updated_at
    from staged
)

select * from final
