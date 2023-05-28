-- Verify citybikes:api_stations on pg
BEGIN;

DO $$
DECLARE
    anon_role TEXT;
    api_schema TEXT;
BEGIN
    EXECUTE 'SELECT utils.get_anon_role()' INTO anon_role;
    EXECUTE 'SELECT utils.get_api_schema()' INTO api_schema;
    ASSERT EXISTS (
        SELECT
            grantee,
            table_name,
            privilege_type
        FROM
            information_schema.role_table_grants
        WHERE
            grantee = anon_role
            AND table_name = 'stations'
            AND table_schema = api_schema
            AND privilege_type = 'SELECT'),
    'Anon role does not have SELECT privileges';
    EXECUTE 'SELECT utils.get_api_schema()' INTO api_schema;
    ASSERT EXISTS (
        SELECT
            grantee,
            table_name,
            privilege_type
        FROM
            information_schema.role_table_grants
        WHERE
            grantee = anon_role
            AND table_name = 'stations'
            AND table_schema = api_schema
            AND privilege_type = 'INSERT'),
    'Anon role does not have INSERT privileges';
    EXECUTE 'SELECT utils.get_api_schema()' INTO api_schema;
    ASSERT EXISTS (
        SELECT
            grantee,
            table_name,
            privilege_type
        FROM
            information_schema.role_table_grants
        WHERE
            grantee = anon_role
            AND table_name = 'stations'
            AND table_schema = api_schema
            AND privilege_type = 'DELETE'),
    'Anon role does not have DELETE privileges';
END
$$
LANGUAGE plpgsql;

ROLLBACK;

