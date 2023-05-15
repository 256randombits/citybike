-- Revert citybikes:postgrest_settings from pg

BEGIN;

DROP SCHEMA utils CASCADE;

COMMIT;
