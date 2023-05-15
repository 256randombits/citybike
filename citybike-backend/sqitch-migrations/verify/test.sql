-- Verify citybikes:test on pg

BEGIN;

DO $$
BEGIN

ASSERT EXISTS (
  SELECT FROM information_schema.tables
  WHERE table_schema = 'public'
  AND table_name = 'tests'
);
END $$;

ROLLBACK;
