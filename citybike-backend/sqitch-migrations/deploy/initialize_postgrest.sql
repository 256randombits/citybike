-- Deploy bikeapp:initialize_postgrest to pg

BEGIN;

CREATE SCHEMA api;
CREATE ROLE web_anon NOLOGIN;
GRANT USAGE ON SCHEMA api TO web_anon;
GRANT web_anon TO authenticator;

COMMIT;
