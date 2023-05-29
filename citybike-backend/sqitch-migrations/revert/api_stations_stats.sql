-- Revert bikeapp:api_stations_stats from pg

BEGIN;

DROP VIEW api.top5_destinations;
DROP VIEW api.top5_destinations_monthly;
DROP VIEW api.journeys_from_station_to_station;
DROP VIEW api.journeys_from_station_to_station_monthly;
DROP VIEW api.stats_departures;
DROP VIEW api.stats_departures_monthly;

COMMIT;
