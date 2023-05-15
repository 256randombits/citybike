-- Verify citybikes:initialize_postgrest on pg

BEGIN;

DO $$
BEGIN

ASSERT EXISTS (
  SELECT FROM information_schema.schemata
  WHERE schema_name = (utils.get_api_schema())
), 'The schema for api should exist.';

ASSERT EXISTS (
  SELECT FROM information_schema.applicable_roles
  WHERE grantee = (utils.get_auth_role())
  AND role_name =  (utils.get_anon_role())
), 'Authenticator role should be able to  become anonymous role.';

ASSERT (
  SELECT
   pg_catalog.has_schema_privilege(
     (utils.get_anon_role()), (utils.get_api_schema()), 'USAGE')
), 'Anonymous role should have usage on api.';

ASSERT NOT (
  SELECT
   pg_catalog.has_schema_privilege(
     (utils.get_auth_role()), (utils.get_api_schema()), 'USAGE')
), 'Authenticator role should not have usage on api.';


END $$;

ROLLBACK;
