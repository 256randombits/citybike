-- Revert bikeapp:initialize_postgrest from pg

BEGIN;

DROP SCHEMA api;
DROP ROLE web_anon;
-- DO NOT DROP AUTHENTICATOR ROLE

COMMIT;
