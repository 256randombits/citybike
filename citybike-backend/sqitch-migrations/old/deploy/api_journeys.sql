-- Deploy citybikes:api_journeys to pg
-- requires: journeys
-- requires: initialize_postgrest
BEGIN;

DO $$
BEGIN
    -- Create view
    EXECUTE FORMAT('
        CREATE VIEW %I.journeys AS
        SELECT
            id,
            departure_time,
            return_time,
            departure_station_id,
            return_station_id,
            distance_in_meters,
            duration_in_seconds
        FROM
            internal.journeys; 
    ', utils.get_api_schema());
    EXECUTE FORMAT('
        GRANT SELECT, DELETE, INSERT
        ON %I.journeys TO %I;
    ', utils.get_api_schema(), utils.get_anon_role());
    NOTIFY pgrst,
    'reload schema';
END
$$
LANGUAGE plpgsql;

COMMIT;

