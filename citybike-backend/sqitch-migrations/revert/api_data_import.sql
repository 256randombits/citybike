-- Revert bikeapp:api_data_import from pg

BEGIN;

DROP FUNCTION api.journey_import(departure_time TIMESTAMPTZ, return_time TIMESTAMPTZ, departure_station_id INTEGER, return_station_id INTEGER, distance_in_meters INTEGER);

COMMIT;
