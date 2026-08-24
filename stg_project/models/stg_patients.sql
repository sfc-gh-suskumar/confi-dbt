with source as (
    select * from {{ source('raw', 'raw_patients') }}
),

cleaned as (
    select
        patient_id,
        trim(first_name) as first_name,
        trim(last_name) as last_name,
        date_of_birth,
        upper(trim(gender)) as gender,
        lower(trim(email)) as email,
        trim(phone) as phone,
        trim(address) as address,
        trim(city) as city,
        upper(trim(state)) as state,
        trim(zip_code) as zip_code,
        trim(insurance_provider) as insurance_provider,
        created_at,
        updated_at
    from source
)

select * from cleaned