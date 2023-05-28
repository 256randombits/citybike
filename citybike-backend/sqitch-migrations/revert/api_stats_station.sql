-- Revert citybikes:api_stats_station from pg

BEGIN;

DO $$
BEGIN
EXECUTE FORMAT('DROP FUNCTION %I.stats(%I.stations)', utils.get_api_schema(), utils.get_api_schema());
EXECUTE FORMAT('DROP VIEW %I.stats_station', utils.get_api_schema());
EXECUTE FORMAT('DROP VIEW %I.stats_monthly_station', utils.get_api_schema());
END
$$;

COMMIT;
