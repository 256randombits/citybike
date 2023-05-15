-- Verify citybikes:postgrest_settings on pg

BEGIN;

DO $$
BEGIN

ASSERT EXISTS (
  SELECT FROM information_schema.routines
  WHERE specific_schema = 'utils'
  AND routine_name = 'get_anon_role'
);

ASSERT EXISTS (
  SELECT FROM information_schema.routines
  WHERE specific_schema = 'utils'
  AND routine_name = 'get_auth_role'
);

ASSERT EXISTS (
  SELECT FROM information_schema.routines
  WHERE specific_schema = 'utils'
  AND routine_name = 'get_api_schema'
);

END $$;

ROLLBACK;
