SELECT
    current_database() AS database_name,
    current_user AS username,
    version() AS postgresql_version;
