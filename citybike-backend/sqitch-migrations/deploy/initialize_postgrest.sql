-- Deploy citybikes:initialize_postgrest to pg
-- requires: postgrest_settings
BEGIN;

DO $$
BEGIN
    EXECUTE FORMAT('CREATE SCHEMA %I', utils.get_api_schema());
    EXECUTE FORMAT('CREATE ROLE %I NOLOGIN', utils.get_anon_role());
    EXECUTE FORMAT('GRANT USAGE ON SCHEMA %I TO %I', utils.get_api_schema(), utils.get_anon_role());
    EXECUTE FORMAT('GRANT %I TO %I', utils.get_anon_role(), utils.get_auth_role());
END
$$;

COMMIT;

