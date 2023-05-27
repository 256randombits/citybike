-- Deploy citybikes:api_stats_station_to_station to pg
-- requires: journeys
-- requires: initialize_postgrest

BEGIN;
DO $$
BEGIN



EXECUTE FORMAT('
  CREATE VIEW %I.stats_monthly_station_departures_to_station AS
    SELECT
        s_dep.id AS station_id,

        s_ret.id AS return_station_id,

        COUNT(j.return_station_id) AS journeys_count,

        AVG(j.distance_in_meters) AS average_distance_in_meters,

        date_trunc(''month'', j.departure_time) month_timestamp

    FROM internal.journeys j
      RIGHT OUTER JOIN internal.stations s_dep ON j.departure_station_id = s_dep.id
      LEFT OUTER JOIN internal.stations s_ret ON j.return_station_id = s_ret.id

    GROUP BY s_dep.id, s_ret.id, month_timestamp;

', utils.get_api_schema ());

EXECUTE FORMAT('
  CREATE VIEW %I.stats_station_departures_to_station AS
    SELECT
        station_id,

        return_station_id,

        SUM(journeys_count) AS journeys_count,

        AVG(average_distance_in_meters) AS average_distance_in_meters

    FROM %I.stats_monthly_station_departures_to_station
    GROUP BY station_id, return_station_id;

', utils.get_api_schema (), utils.get_api_schema ());

EXECUTE FORMAT('
  CREATE VIEW %I.stats_monthly_station_returns_to_station AS
    SELECT
        s_ret.id AS station_id,

        s_dep.id AS deparure_station_id,

        COUNT(j.departure_station_id) AS journeys_count,

        AVG(j.distance_in_meters) AS average_distance_in_meters,

        date_trunc(''month'', j.departure_time) month_timestamp

    FROM internal.journeys j
      RIGHT OUTER JOIN internal.stations s_ret ON j.return_station_id = s_ret.id
      LEFT OUTER JOIN internal.stations s_dep ON j.departure_station_id = s_dep.id

    GROUP BY s_ret.id, s_dep.id, month_timestamp;

', utils.get_api_schema ());

EXECUTE FORMAT('
  CREATE VIEW %I.stats_station_returns_to_station AS
    SELECT
        station_id,

        deparure_station_id,

        SUM(journeys_count) AS journeys_count,

        AVG(average_distance_in_meters) AS average_distance_in_meters

    FROM %I.stats_monthly_station_returns_to_station

    GROUP BY station_id, deparure_station_id;

', utils.get_api_schema (), utils.get_api_schema ());


-- Privileges

EXECUTE FORMAT('
  GRANT SELECT ON %I.stats_station_departures_to_station TO %I;
', utils.get_api_schema (), utils.get_anon_role ());

EXECUTE FORMAT('
  GRANT SELECT ON %I.stats_monthly_station_departures_to_station TO %I;
', utils.get_api_schema (), utils.get_anon_role ());

EXECUTE FORMAT('
  GRANT SELECT ON %I.stats_station_returns_to_station TO %I;
', utils.get_api_schema (), utils.get_anon_role ());

EXECUTE FORMAT('
  GRANT SELECT ON %I.stats_monthly_station_returns_to_station TO %I;
', utils.get_api_schema (), utils.get_anon_role ());

NOTIFY pgrst,
'reload schema';

END
$$
LANGUAGE plpgsql;

COMMIT;
