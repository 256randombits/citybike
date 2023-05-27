-- Deploy citybikes:api_stats_station_returns to pg
-- requires: journeys
-- requires: initialize_postgrest

BEGIN;

DO $$
BEGIN

EXECUTE FORMAT('
  CREATE VIEW %I.stats_station_returns AS
    SELECT
        s_dep.id AS id,

        COUNT(j.return_station_id) AS amount,

        AVG(j.distance_in_meters) AS average_distance_in_meters

    FROM internal.journeys j
      RIGHT OUTER JOIN internal.stations s_dep ON j.return_station_id = s_dep.id

    GROUP BY s_dep.id;

', utils.get_api_schema ());


EXECUTE FORMAT('
  CREATE VIEW %I.stats_monthly_station_returns AS
    SELECT
        s_dep.id AS id,

        COUNT(j.return_station_id) AS amount,

        date_trunc(''month'', j.return_time) month_timestamp

    FROM internal.journeys j
      RIGHT OUTER JOIN internal.stations s_dep ON j.return_station_id = s_dep.id

    GROUP BY s_dep.id, month_timestamp;

', utils.get_api_schema ());

-- Privileges

EXECUTE FORMAT('
  GRANT SELECT ON %I.stats_station_returns TO %I;
', utils.get_api_schema (), utils.get_anon_role ());

EXECUTE FORMAT('
  GRANT SELECT ON %I.stats_monthly_station_returns TO %I;
', utils.get_api_schema (), utils.get_anon_role ());

NOTIFY pgrst,
'reload schema';

END
$$
LANGUAGE plpgsql;

COMMIT;
