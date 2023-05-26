-- Revert citybikes:api_station_stats from pg

BEGIN;

DO $$
BEGIN
    EXECUTE FORMAT('
        DROP VIEW %I.station_stats;', utils.get_api_schema());
END
$$;

COMMIT;
