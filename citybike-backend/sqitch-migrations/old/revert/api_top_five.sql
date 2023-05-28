-- Revert citybikes:api_top_five from pg

BEGIN;

DO $$
BEGIN
-- EXECUTE FORMAT('DROP VIEW %I.top5_origins', utils.get_api_schema(), utils.get_api_schema());
EXECUTE FORMAT('DROP FUNCTION %I.top5_destinations(%I.stats_station)', utils.get_api_schema(), utils.get_api_schema());
EXECUTE FORMAT('DROP FUNCTION %I.rank1_dest(%I.top5_destinations)', utils.get_api_schema(), utils.get_api_schema());
EXECUTE FORMAT('DROP VIEW %I.top5_destinations', utils.get_api_schema(), utils.get_api_schema());
END
$$;

COMMIT;
