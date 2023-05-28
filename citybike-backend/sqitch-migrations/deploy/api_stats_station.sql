-- Deploy citybikes:api_stats_station to pg
-- requires: journeys
-- requires: initialize_postgrest
-- requires: api_stats_station_departures
-- requires: api_stats_station_returns
-- requires: api_stats_station_to_station

BEGIN;
DO $$
BEGIN

EXECUTE FORMAT('
  CREATE VIEW %I.stats_station AS
    SELECT
      s.id AS station_id,
      s.name_fi AS name_fi,
      s.address_fi AS address_fi,

      ssd.departures_count AS departures_count,
      ssr.returns_count AS returns_count,

      ssd.average_distance_in_meters AS average_departure_distance_in_meters,
      ssr.average_distance_in_meters AS average_return_distance_in_meters

    FROM internal.stations s
      INNER JOIN %I.stats_station_departures ssd ON s.id = ssd.station_id
      INNER JOIN %I.stats_station_returns ssr ON s.id = ssr.station_id;
', utils.get_api_schema (), utils.get_api_schema (), utils.get_api_schema (), utils.get_api_schema (), utils.get_api_schema ());

EXECUTE FORMAT('
  CREATE VIEW %I.stats_monthly_station AS
    SELECT
      s.id AS station_id,
      s.name_fi AS name_fi,
      s.address_fi AS address_fi,

      ssd.departures_count AS departures_count,
      ssr.returns_count AS returns_count,

      ssd.average_distance_in_meters AS average_departure_distance_in_meters,
      ssr.average_distance_in_meters AS average_return_distance_in_meters

    FROM internal.stations s
      LEFT OUTER JOIN %I.stats_monthly_station_departures ssd ON s.id = ssd.station_id
      FULL OUTER JOIN %I.stats_monthly_station_returns ssr ON s.id = ssr.station_id AND ssd.month_timestamp = ssr.month_timestamp;
', utils.get_api_schema (), utils.get_api_schema (), utils.get_api_schema ());

-- https://postgrest.org/en/stable/references/api/resource_embedding.html#computed-relationships
EXECUTE FORMAT('
  CREATE FUNCTION %I.stats(%I.stations) RETURNS SETOF %I.stats_station ROWS 1 AS $function$
    SELECT * FROM %I.stats_station WHERE station_id = $1.id
  $function$ STABLE LANGUAGE SQL;
', utils.get_api_schema(), utils.get_api_schema(), utils.get_api_schema(), utils.get_api_schema());

-- Privileges
EXECUTE FORMAT('
  GRANT SELECT ON %I.stats_station TO %I;
', utils.get_api_schema (), utils.get_anon_role ());

EXECUTE FORMAT('
  GRANT SELECT ON %I.stats_monthly_station TO %I;
', utils.get_api_schema (), utils.get_anon_role ());

NOTIFY pgrst,
'reload schema';

END
$$
LANGUAGE plpgsql;

COMMIT;
