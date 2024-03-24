# snowflake_learn

## Snow bootstrap

### Setup snow command
We can use an admin account to create a database and set it up for public access.

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
     -q "SELECT CURRENT_VERSION();" \
     --connection admin \
     --password $SNOWFLAKE_PASSWORD

   ```
1. Setup a new user role in snowflake for cli commands , role PUBLIC
2. Grant warehouse public role, permissions; MONITOR and USAGE

NOTE: you can remove a connection from:
 - AppData\Local\snowflake\config.toml

- TODO: setup commands to create cli account

### Create Database
- https://docs.snowflake.com/en/sql-reference/sql/create-database
-1. Create database 
    ```
    export SNOWFLAKE_PASSWORD=****
    snow sql \
      -q "CREATE DATABASE IF NOT EXISTS DEMO DATA_RETENTION_TIME_IN_DAYS = 8;" \
      --connection admin \
      --password "${SNOWFLAKE_PASSWORD}"
    ```

## Schema Migrations
`schemachange` is pretty old and the project doesn't appear to be maintained but shows up in our training.

Lets see if we can get it to work.

### Install
- NOTE, the normal install process doesn't work, however that might be a problem with my Windows setup.
- Some raw install steps to workaround that.
```
mkdir -p ~/GitHub/Snowflake-Labs
cd ~/GitHub/Snowflake-Labs
git clone https://github.com/Snowflake-Labs/schemachange
cd schemachange
pip install Jinja2 pandas PyYAML snowflake-connector-pythonpip install 
alias schemachange='python $HOME/GitHub/Snowflake-Labs/schemachange/schemachange/cli.py'
```

### Call

Example call
```
export $GITHUB_WORKSPACE='/home/wenlock/GitHub/sfc-gh-eraigosa/snowflake_learn'
export SF_ROLE=PUBLIC
export SF_WAREHOUSE=COMPUTE_WH
export SF_DATABASE=DEMO

# set additional secrets
# SF_ACCOUNT
# SF_USERNMAE
# SNOWFLAKE_PASSWORD

schemachange -f $GITHUB_WORKSPACE/migrations \
  -a $SF_ACCOUNT \
  -u $SF_USERNAME \
  -r $SF_ROLE \
  -w $SF_WAREHOUSE \
  -d $SF_DATABASE \
  -c $SF_DATABASE.SCHEMACHANGE.CHANGE_HISTORY \
  --create-change-history-table
```
