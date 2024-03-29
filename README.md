# snowflake_learn

## Snow bootstrap

### Setup snow command
We can use an [admin](https://docs.snowflake.com/en/user-guide/security-access-control-considerations) account to create a database and set it up for public access. As an aside, remember to [enable MFA](https://docs.snowflake.com/en/user-guide/security-mfa) since. That will help you protect your key admin account.

Install the snow cli to get started.
- https://docs.snowflake.com/en/developer-guide/snowflake-cli-v2/installation/installation
1. Setup a connection with `snow connection add`
   - Suggest creating two connections, one for admin operations and one for user operations.
   - Ideally secure the admin account by not providing the password, since we'll use this rarely.
```
Name for this connection: admin
Snowflake account name: <Value from Admin->Accounts, ACCOUNT column>
Snowflake username: <Value from Admin->Users & Roles, NAME with ACCOUNTADMIN>
Snowflake password [optional]: <skip>
Role for the connection [optional]: ACCOUNTADMIN
Warehouse for the connection [optional]: <Value from Admin->Warehouses>
Database for the connection [optional]: SNOWFLAKE
Schema for the connection [optional]: CORE
Connection host [optional]: <Value from Admin->Accounts, click account being used on "..." icon, Manage Urls, Current URL without https:// >
Connection port [optional]: <skip>
Snowflake region [optional]: <skip>
Authentication method [optional]: <skip>
Path to private key file [optional]: <skip>
Wrote new connection admin ....
```
   - normally we can test connections with password setup as follows `snow connection test --connection admin` however, without that we should try:
   ```
   snow sql \
     -q "\
        SELECT \
          CURRENT_VERSION() as version, \
          CURRENT_USER() as login_user, \
          CURRENT_ROLE() as role, \
          CURRENT_ACCOUNT() as locator, \
          CURRENT_ACCOUNT_NAME() as account_name, \
          CURRENT_ORGANIZATION_NAME() as org_name, \
          CONCAT_WS(                                     \
                     '',                                 \
                     'https://',                         \
                     LOWER(CURRENT_ORGANIZATION_NAME()), \
                     '-',                                \
                     LOWER(CURRENT_ACCOUNT_NAME()),      \
                     '.snowflakecomputing.com'           \
          ) as URL \
        ;\
      " \
     --connection admin \
     --password "${SNOWFLAKE_ADMIN_PASSWORD}"

   ```
   NOTE, this shouldn't cost us much since we technically don't use the warehouse to get the version.

NOTE: you can remove a connection from:
 - AppData\Local\snowflake\config.toml


### Create CLI Account
- TODO: setup commands to create cli account
ie;
```
CREATE OR REPLACE USER CLI_USER
PASSWORD = '' -- add a secure password, TODO: dynamic password
LOGIN_NAME = 'cli_user' -- add a login name
FIRST_NAME = 'bot'
LAST_NAME = 'user'
EMAIL = '' -- leave empty
MUST_CHANGE_PASSWORD = false -- ensures a password reset on first login
DEFAULT_WAREHOUSE = COMPUTE_WH; -- set default warehouse to COMPUTE_WH
-- need default role
```

Normally I'd want to use a command prompt way to create the account but ran out of time to do this, so I've left a TODO. For now do the following.
1. Go to Admin-> Users, choose + User button
2. Provide some User Name, fill in password, you can skip forcing to change the password since it will be your user account.
3. Got to Advanced User Options and fill in the rest of the fields.
4. Set the Default Role to `PUBLIC`
5. Pick a warehouse you plan to use with the account, ie; `COMPUTE_WH`
6. You can pick the default schema we're learning with: `DEMO.DEMO`.

The role needs to have some permissions to use the `COMPUTE_WH`.
- Grant warehouse public role, permissions; `MONITOR` and `USAGE`.

TODO: need to try this
```
-- grant role PUBLIC to our CLI_USER
GRANT ROLE PUBLIC TO USER CLI_USER;

-- grant usage on the COMPUTE_WH warehouse to our PUBLIC role
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE PUBLIC;
GRANT MONITOR ON WAREHOUSE COMPUTE_WH TO ROLE PUBLIC;
```

### Create Database
- https://docs.snowflake.com/en/sql-reference/sql/create-database
1. [Create database](https://docs.snowflake.com/en/sql-reference/sql/create-database)
    ```
    snow sql \
      -q "CREATE DATABASE IF NOT EXISTS DEMO DATA_RETENTION_TIME_IN_DAYS = 1;" \
      --connection admin \
      --password "${SNOWFLAKE_ADMIN_PASSWORD}"
    ```

### Create Schema
Create a new schema called `DEMO` to use on the `DEMO` database.
- Grant admin `CREATE SCHEMA`, `MONITOR` and `USAGE` permissions for `ACCOUNTADMIN` on `DEMO`.
```
    snow sql \
      -q " \
        GRANT USAGE ON DATABASE DEMO TO ROLE PUBLIC; \
        GRANT CREATE SCHEMA ON DATABASE DEMO TO ROLE PUBLIC; \
        GRANT MONITOR ON DATABASE DEMO TO ROLE PUBLIC; \
      " \
      --connection admin \
      --password "${SNOWFLAKE_ADMIN_PASSWORD}"
```
- More docs: https://docs.snowflake.com/en/user-guide/security-access-control-considerations

Check to see if we can see the database:
```
    snow sql \
      -q " \
        SHOW DATABASES; \
      " \
      --connection admin \
      --password "${SNOWFLAKE_ADMIN_PASSWORD}"
```

Create the schema
```
    snow sql \
      -q "CREATE SCHEMA IF NOT EXISTS DEMO.DEMO;"
      --connection admin \
      --password "${SNOWFLAKE_ADMIN_PASSWORD}"
```

Show database as cliuser
```
    snow sql \
      -q " \
        SHOW DATABASES; \
      " \
      --connection cliuser
```

### Assign Roles
We'll skip creating a new role and just use the `PUBLIC` role to setup the database [access and schema access](https://docs.snowflake.com/en/user-guide/security-access-control-overview#label-access-control-overview-privileges) for the `DEMO.DEMO` database schema.

We'll need the [privledge](https://docs.snowflake.com/en/user-guide/security-access-control-privileges#database-privileges) `USAGE` access on `DEMO.DEMO`, add it with this command:
```
    snow sql \
      -q " \
      GRANT USAGE ON DATABASE DEMO TO ROLE PUBLIC; \
      GRANT USAGE ON SCHEMA DEMO.DEMO TO ROLE PUBLIC; \
      " \
      --connection admin \
      --password "${SNOWFLAKE_ADMIN_PASSWORD}"
```
-

## Schema Migrations
The tool `schemachange` is pretty old and the project doesn't appear to be maintained but shows up in snowflake documentation.

You'll need python installed:
```
sudo apt-get install python3 python3-pip python3-venv openssl
sudo pip3 install pyopenssl
python3 -m pip install pip --upgrade
sudo pip3 install pyopenssl --upgrade
```

Lets see if we can get it to work.

### Install schemachange
- NOTE, the normal install process doesn't work, however that might be a problem with my Windows setup.
- Some raw install steps to workaround that.
```
mkdir -p ~/GitHub/Snowflake-Labs
cd ~/GitHub/Snowflake-Labs
git clone https://github.com/Snowflake-Labs/schemachange
cd schemachange
pip install Jinja2 pandas PyYAML snowflake-connector-python
alias schemachange='python $HOME/GitHub/Snowflake-Labs/schemachange/schemachange/cli.py'
```

### Call

Example call
```
export GITHUB_WORKSPACE='/home/wenlock/GitHub/sfc-gh-eraigosa/snowflake_learn'
export SF_ROLE=PUBLIC
export SF_WAREHOUSE=COMPUTE_WH
export SF_DATABASE=DEMO
export SF_SCHEMA=DEMO

# set additional secrets
# SF_ACCOUNT = CONCAT_WS(                                     \
#                 LOWER(CURRENT_ORGANIZATION_NAME()), \
#                 '-',                                \
#                 LOWER(CURRENT_ACCOUNT_NAME()),      \
#                )
# SF_USERNMAE = cliuser
# SNOWFLAKE_PASSWORD

# on windows wsl
schemachange \
  -f $GITHUB_WORKSPACE/migrations \
  -a $SF_ACCOUNT \
  -u $SF_USERNAME \
  -r $SF_ROLE \
  -w $SF_WAREHOUSE \
  -d $SF_DATABASE \
  -s $SF_SCHEMA \
  -c $SF_DATABASE.SCHEMACHANGE.CHANGE_HISTORY \
  --create-change-history-table
```

## Using the database

### Setup snowsql client
- https://docs.snowflake.com/en/user-guide/snowsql

### Worksheets

### Usage
- Simple queries

### Saving worksheets

## Other Examples

- https://developers.snowflake.com/#listings?wvideo=haqeh4q2se

## Another DDL tool
- https://github.com/littleK0i/SnowDDL?tab=readme-ov-file
