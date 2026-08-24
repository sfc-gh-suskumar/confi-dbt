with source as (
    select * from {{ source('raw', 'raw_encounters') }}
),

cleaned as (
    select
        encounter_id,
        patient_id,
        provider_id,
        encounter_date,
        upper(trim(encounter_type)) as encounter_type,
        trim(chief_complaint) as chief_complaint,
        discharge_date,
        trim(discharge_disposition) as discharge_disposition,
        total_charges,
        trim(facility) as facility,
        datediff('day', encounter_date, discharge_date) as length_of_stay_days,
        created_at,
        updated_at
    from source
)

select * from cleaned