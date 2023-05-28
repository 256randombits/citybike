-- Verify bikeapp:initialize_postgrest on pg
BEGIN;

DO $$
BEGIN
  ASSERT EXISTS(
    SELECT
    FROM
      information_schema.schemata
    WHERE
      schema_name = 'api'), 'The schema ''api'' should exist!';
  ASSERT EXISTS(
    SELECT
    FROM
      information_schema.applicable_roles
    WHERE
      grantee = 'authenticator'
      AND role_name = 'web_anon'),
  'Authenticator role should be able to become anonymous role.';
  ASSERT(
    SELECT
      pg_catalog.HAS_SCHEMA_PRIVILEGE('web_anon', 'api', 'USAGE')),
  'Anonymous role should have usage on api.';
  ASSERT NOT(
    SELECT
      pg_catalog.HAS_SCHEMA_PRIVILEGE('authenticator', 'api', 'USAGE')),
  'Authenticator role should not have usage on api.';
END
$$;

ROLLBACK;
