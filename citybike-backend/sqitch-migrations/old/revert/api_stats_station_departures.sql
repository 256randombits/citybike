-- Revert citybikes:api_stats_station_departures from pg

BEGIN;

DO $$
BEGIN
EXECUTE FORMAT('DROP VIEW %I.stats_station_departures', utils.get_api_schema());
EXECUTE FORMAT('DROP VIEW %I.stats_monthly_station_departures', utils.get_api_schema());
END
$$;

COMMIT;
