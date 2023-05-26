-- Deploy citybikes:api_station_stats to pg
-- requires: journeys
-- requires: initialize_postgrest
BEGIN;

DO $$
BEGIN
    -- Create
EXECUTE FORMAT('CREATE VIEW %I.station_stats AS
        SELECT
            stations.id AS id,
            stations.name_fi AS name_fi,
            departure_counts.departure_count AS departure_count,
            return_counts.return_count AS return_count
            FROM internal.stations stations
            INNER JOIN
                ( SELECT s.id AS id, COUNT(*) AS departure_count
                  FROM internal.stations s
                  RIGHT OUTER JOIN internal.journeys j ON j.departure_station_id = s.id
                  GROUP BY s.id
                ) AS departure_counts ON departure_counts.id = stations.id
            INNER JOIN
                ( SELECT s.id AS id, COUNT(*) AS return_count
                  FROM internal.stations s
                  RIGHT OUTER JOIN internal.journeys j ON j.return_station_id = s.id
                  GROUP BY s.id
                ) AS return_counts ON return_counts.id = stations.id;
    ', utils.get_api_schema());

    -- Privileges
    EXECUTE FORMAT('
    GRANT SELECT ON %I.station_stats TO %I;
    ',
    utils.get_api_schema(),
    utils.get_anon_role());
    -- Reload
    NOTIFY pgrst,
    'reload schema';
END
$$
LANGUAGE plpgsql;

COMMIT;

