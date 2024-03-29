-- helo world test, from this training
-- https://quickstarts.snowflake.com/guide/devops_dcm_schemachange_github/index.html#3
-- works with ; https://github.com/Snowflake-Labs/schemachange?tab=readme-ov-file#repeatable-script-naming
CREATE IF NOT EXISTS SCHEMA DEMO;
CREATE TABLE IF NOT EXISTS HELLO_WORLD
(
   FIRST_NAME VARCHAR
  ,LAST_NAME VARCHAR
);
