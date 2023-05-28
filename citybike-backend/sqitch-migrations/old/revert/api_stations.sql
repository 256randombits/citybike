-- Revert citybikes:api_stations from pg
BEGIN;

DO $$
BEGIN
    EXECUTE FORMAT('
        DROP VIEW %I.stations;', utils.get_api_schema());
END
$$;

COMMIT;

