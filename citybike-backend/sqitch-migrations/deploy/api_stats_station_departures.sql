-- Deploy citybikes:api_stats_station_departures to pg
-- requires: journeys
-- requires: initialize_postgrest

BEGIN;
DO $$
BEGIN

EXECUTE FORMAT('
  CREATE VIEW %I.stats_station_departures AS
    SELECT
        s_dep.id AS station_id,

        COUNT(j.departure_station_id) AS amount,

        AVG(j.distance_in_meters) AS average_distance_in_meters

    FROM internal.journeys j
      RIGHT OUTER JOIN internal.stations s_dep ON j.departure_station_id = s_dep.id

    GROUP BY s_dep.id;

', utils.get_api_schema ());


EXECUTE FORMAT('
  CREATE VIEW %I.stats_monthly_station_departures AS
    SELECT
        s_dep.id AS station_id,

        COUNT(j.departure_station_id) AS amount,

        AVG(j.distance_in_meters) AS average_distance_in_meters,

        date_trunc(''month'', j.departure_time) month_timestamp

    FROM internal.journeys j
      RIGHT OUTER JOIN internal.stations s_dep ON j.departure_station_id = s_dep.id

    GROUP BY s_dep.id, month_timestamp;

', utils.get_api_schema ());

-- Privileges

EXECUTE FORMAT('
  GRANT SELECT ON %I.stats_station_departures TO %I;
', utils.get_api_schema (), utils.get_anon_role ());

EXECUTE FORMAT('
  GRANT SELECT ON %I.stats_monthly_station_departures TO %I;
', utils.get_api_schema (), utils.get_anon_role ());

NOTIFY pgrst,
'reload schema';

END
$$
LANGUAGE plpgsql;

COMMIT;
