-- Revert bikeapp:test_utils from pg

BEGIN;

DROP SCHEMA test_utils CASCADE;

COMMIT;
