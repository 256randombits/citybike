-- Revert bikeapp:api_stations_stats from pg

BEGIN;

DROP VIEW api.stats_departures;
DROP VIEW api.stats_departures_monthly;

COMMIT;
