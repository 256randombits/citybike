-- Revert bikeapp:api_stations_stats from pg

BEGIN;

DO $$
BEGIN
FOR counter in 1..5 LOOP
  EXECUTE FORMAT(
    'DROP FUNCTION api.rank%s_destination(api.top5_destinations);
    ', counter);
END loop;
END$$;

DROP FUNCTION api.stats(api.stations);
DROP FUNCTION api.top5_destinations(api.stats_station);
DROP VIEW api.stats_station;
DO $$
BEGIN
FOR counter in 1..5 LOOP
  EXECUTE FORMAT(
    'DROP FUNCTION api.rank%s_destination(api.top5_destinations_monthly);
    ', counter);
END loop;
END$$;

DROP FUNCTION api.stats_monthly(api.stations);
DROP FUNCTION api.top5_destinations(api.stats_station_monthly);
DROP VIEW api.stats_station_monthly;

DROP VIEW api.top5_destinations;
DROP VIEW api.top5_destinations_monthly;
DROP VIEW api.journeys_from_station_to_station;
DROP VIEW api.journeys_from_station_to_station_monthly;
DROP VIEW api.stats_departures;
DROP VIEW api.stats_departures_monthly;

COMMIT;
