-- Revert citybikes:initialize_postgrest from pg
BEGIN;

DO $$
BEGIN
    EXECUTE FORMAT('DROP SCHEMA %I CASCADE', utils.get_api_schema());
    EXECUTE FORMAT('DROP ROLE %I', utils.get_anon_role());
END
$$;

COMMIT;

