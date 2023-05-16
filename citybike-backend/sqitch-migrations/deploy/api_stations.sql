-- Deploy citybikes:api_stations to pg
-- requires: stations
-- requires: initialize_postgrest
BEGIN;

DO $$
BEGIN
    -- View
    EXECUTE FORMAT('
        CREATE VIEW %I.stations AS
        SELECT
            id,
            name_fi,
            name_sv,
            name_en,
            address_fi,
            address_sv,
            city_fi,
            city_sv,
            operator,
            capacity,
            longitude AS x,
            latitude AS y
        FROM
            internal.stations;
    ', utils.get_api_schema());
    -- Permissions
    EXECUTE FORMAT('
        GRANT SELECT, DELETE, INSERT
        ON %I.stations TO %I;
    ', utils.get_api_schema(), utils.get_anon_role());
    NOTIFY pgrst,
    'reload schema';
END
$$;

COMMIT;

