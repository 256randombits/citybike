-- Revert citybikes:initialize_postgrest from pg

BEGIN;

DO $$
BEGIN

EXECUTE format
  ('DROP SCHEMA %I CASCADE', utils.get_api_schema());

EXECUTE format
  ('DROP ROLE %I', utils.get_anon_role());

END $$;

COMMIT;
