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
            journeys.id AS id,
            journeys.departure_time AS departure_time,
            journeys.return_time AS return_time,
            departure_stations.id AS departure_station_id,
            departure_stations.name_fi AS departure_station_name,
            return_stations.id AS return_station_id,
            return_stations.name_fi AS return_station_name,
            journeys.distance_in_meters
        FROM
            internal.journeys journeys
            INNER JOIN internal.stations departure_stations
                ON journeys.departure_station_id = departure_stations.id
            INNER JOIN internal.stations return_stations
                ON journeys.return_station_id = return_stations.id;
    ', utils.get_api_schema());
    -- Create trigger
    EXECUTE FORMAT('
        CREATE FUNCTION %I.journeys_insert_row()
            RETURNS TRIGGER
        AS $trigger$
        BEGIN
            INSERT INTO internal.journeys(
                departure_time,
                return_time,
                departure_station_id,
                return_station_id,
                distance_in_meters)
            VALUES(
                NEW.departure_time,
                NEW.return_time,
                NEW.departure_station_id,
                NEW.return_station_id,
                NEW.distance_in_meters);
            RETURN NEW;
        END;
        $trigger$
        LANGUAGE plpgsql
        SECURITY DEFINER SET search_path = internal, pg_temp;
    ', utils.get_api_schema());
    -- Set trigger
    EXECUTE FORMAT('
    CREATE OR REPLACE TRIGGER journeys_insert
        INSTEAD OF INSERT ON %I.journeys
        FOR EACH ROW
        EXECUTE FUNCTION %I.journeys_insert_row ();
    ',utils.get_api_schema(),utils.get_api_schema());
    -- Permissions
    EXECUTE FORMAT('
        REVOKE ALL ON FUNCTION %I.journeys_insert_row() FROM PUBLIC;
    ', utils.get_api_schema());
    EXECUTE FORMAT('
        GRANT EXECUTE ON FUNCTION %I.journeys_insert_row() TO %I;
    ', utils.get_api_schema(), utils.get_anon_role());
    EXECUTE FORMAT('
        GRANT SELECT, DELETE, INSERT
        ON %I.journeys TO %I;
    ', utils.get_api_schema(), utils.get_anon_role());
END
$$
LANGUAGE plpgsql;

NOTIFY pgrst, 'reload schema';
COMMIT;
