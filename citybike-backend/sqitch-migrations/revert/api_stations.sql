-- Revert bikeapp:api_stations from pg

BEGIN;

DROP VIEW api.stations;

COMMIT;
