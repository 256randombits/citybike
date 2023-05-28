-- Revert citybikes:api_stats_station_to_station from pg

BEGIN;

DO $$
BEGIN
EXECUTE FORMAT('DROP VIEW %I.stats_station_departures_to_station', utils.get_api_schema());
EXECUTE FORMAT('DROP VIEW %I.stats_monthly_station_departures_to_station', utils.get_api_schema());
EXECUTE FORMAT('DROP VIEW %I.stats_station_returns_to_station', utils.get_api_schema());
EXECUTE FORMAT('DROP VIEW %I.stats_monthly_station_returns_to_station', utils.get_api_schema());
END
$$;

COMMIT;
