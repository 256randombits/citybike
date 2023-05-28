-- Revert citybikes:api_stats_station_returns from pg

BEGIN;

DO $$
BEGIN
EXECUTE FORMAT('DROP VIEW %I.stats_station_returns', utils.get_api_schema());
EXECUTE FORMAT('DROP VIEW %I.stats_monthly_station_returns', utils.get_api_schema());
END
$$;

COMMIT;
