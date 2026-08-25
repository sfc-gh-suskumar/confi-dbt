-- Deploy dbt projects to QA from Git repository (lowercase repo name requires quoting)
-- Co-authored with CoCo

-- Fetch latest code from Git
ALTER GIT REPOSITORY CONFI_DB_QA.GITREPO."confi_dbt_repo" FETCH;

-- Deploy STG project
CREATE OR REPLACE DBT PROJECT CONFI_DB_QA.STG.STG_PROJECT
  FROM @CONFI_DB_QA.GITREPO."confi_dbt_repo"/branches/main/stg_project/
  DBT_VERSION = '1.9.4';

-- Deploy DDS project
CREATE OR REPLACE DBT PROJECT CONFI_DB_QA.DDS.DDS_PROJECT
  FROM @CONFI_DB_QA.GITREPO."confi_dbt_repo"/branches/main/dds_project/
  DBT_VERSION = '1.9.4';

-- Deploy ADS project
CREATE OR REPLACE DBT PROJECT CONFI_DB_QA.ADS.ADS_PROJECT
  FROM @CONFI_DB_QA.GITREPO."confi_dbt_repo"/branches/main/ads_project/
  DBT_VERSION = '1.9.4';
