-- Analytical summary joining patients with encounter stats, incremental on patient_id
-- Co-authored with CoCo
{{
  config(
    unique_key = 'patient_id',
    incremental_strategy = 'merge',
    on_schema_change = 'append_new_columns'
  )
}}

{% if is_incremental() %}
with incremental_filter as (
    select max(dbt_updated_at) as max_updated_at from {{ this }}
),

encounters as (
    select * from {{ source('dds', 'fct_encounters') }}
    where updated_at > (select max_updated_at from incremental_filter)
),
{% else %}
with encounters as (
    select * from {{ source('dds', 'fct_encounters') }}
),
{% endif %}

patients as (
    select * from {{ source('dds', 'dim_patients') }}
),

encounter_stats as (
    select
        patient_id,
        count(distinct encounter_id) as total_encounters,
        sum(total_charges) as total_charges,
        avg(total_charges) as avg_charges_per_encounter,
        min(encounter_date) as first_encounter_date,
        max(encounter_date) as last_encounter_date,
        avg(length_of_stay_days) as avg_length_of_stay_days
    from encounters
    group by patient_id
),

final as (
    select
        p.patient_id,
        p.full_name,
        p.age,
        p.gender,
        p.insurance_provider,
        p.city,
        p.state,
        coalesce(es.total_encounters, 0) as total_encounters,
        coalesce(es.total_charges, 0) as total_charges,
        es.avg_charges_per_encounter,
        es.first_encounter_date,
        es.last_encounter_date,
        es.avg_length_of_stay_days,
        current_timestamp() as dbt_updated_at
    from patients p
    left join encounter_stats es on p.patient_id = es.patient_id
)

select * from final
