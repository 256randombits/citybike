-- Deploy citybikes:api_top_five to pg
-- requires: api_stats_station

BEGIN;
DO $$
BEGIN

EXECUTE FORMAT('
  CREATE FUNCTION %I.top5_destinations(%I.stats_station, OUT station_id INT, OUT rank1 INT, OUT rank2 INT, OUT rank3 INT, OUT rank4 INT, OUT rank5 INT) RETURNS SETOF record ROWS 1 AS $function$
    SELECT * FROM (SELECT
          station_id, 
    		nth_value(return_station_id, 1) OVER w rank1,
    		nth_value(return_station_id, 2) OVER w rank2,
    		nth_value(return_station_id, 3) OVER w rank3,
    		nth_value(return_station_id, 4) OVER w rank4,
    		nth_value(return_station_id, 5) OVER w rank5
    FROM  api.stats_station_departures_to_station
    WHERE station_id = $1.station_id
    WINDOW w AS (ORDER BY journeys_count DESC)
    ORDER BY journeys_count DESC
    LIMIT 5) AS top5
    ORDER BY rank5, rank4, rank3, rank2, rank1 DESC
    LIMIT 1
  $function$ STABLE LANGUAGE SQL;
', utils.get_api_schema(), utils.get_api_schema(), utils.get_api_schema(), utils.get_api_schema());

EXECUTE FORMAT('
  CREATE FUNCTION %I.top5_origins(%I.stats_station, OUT station_id INT, OUT rank1 INT, OUT rank2 INT, OUT rank3 INT, OUT rank4 INT, OUT rank5 INT) RETURNS SETOF record ROWS 1 AS $function$
    SELECT * FROM (SELECT
          station_id, 
    		nth_value(departure_station_id, 1) OVER w rank1,
    		nth_value(departure_station_id, 2) OVER w rank2,
    		nth_value(departure_station_id, 3) OVER w rank3,
    		nth_value(departure_station_id, 4) OVER w rank4,
    		nth_value(departure_station_id, 5) OVER w rank5
    FROM  api.stats_station_returns_to_station
    WHERE station_id = $1.station_id
    WINDOW w AS (ORDER BY journeys_count DESC)
    ORDER BY journeys_count DESC
    LIMIT 5) AS top5
    ORDER BY rank5, rank4, rank3, rank2, rank1 DESC
    LIMIT 1
  $function$ STABLE LANGUAGE SQL;
', utils.get_api_schema(), utils.get_api_schema(), utils.get_api_schema(), utils.get_api_schema());

-- EXECUTE FORMAT('
--   CREATE FUNCTION %I.top5_destinations(%I.stats_monthly_station, OUT station_id INT, OUT rank1 INT, OUT rank2 INT, OUT rank3 INT, OUT rank4 INT, OUT rank5 INT) RETURNS SETOF record ROWS 1 AS $function$
--     SELECT * FROM (SELECT
--           station_id, 
--     		nth_value(return_station_id, 1) OVER w rank1,
--     		nth_value(return_station_id, 2) OVER w rank2,
--     		nth_value(return_station_id, 3) OVER w rank3,
--     		nth_value(return_station_id, 4) OVER w rank4,
--     		nth_value(return_station_id, 5) OVER w rank5
--     FROM  api.stats_station_departures_to_station
--     WHERE station_id = $1.station_id
--     WINDOW w AS (ORDER BY journeys_count DESC)
--     ORDER BY journeys_count DESC
--     LIMIT 5) AS top5
--     ORDER BY rank5, rank4, rank3, rank2, rank1 DESC
--     LIMIT 1
--   $function$ STABLE LANGUAGE SQL;
-- ', utils.get_api_schema(), utils.get_api_schema(), utils.get_api_schema(), utils.get_api_schema());
--
-- EXECUTE FORMAT('
--   CREATE FUNCTION %I.top5_origins(%I.stats_monthly_station, OUT station_id INT, OUT rank1 INT, OUT rank2 INT, OUT rank3 INT, OUT rank4 INT, OUT rank5 INT) RETURNS SETOF record ROWS 1 AS $function$
--     SELECT * FROM (SELECT
--           station_id, 
--     		nth_value(departure_station_id, 1) OVER w rank1,
--     		nth_value(departure_station_id, 2) OVER w rank2,
--     		nth_value(departure_station_id, 3) OVER w rank3,
--     		nth_value(departure_station_id, 4) OVER w rank4,
--     		nth_value(departure_station_id, 5) OVER w rank5
--     FROM  api.stats_station_returns_to_station
--     WHERE station_id = $1.station_id
--     WINDOW w AS (ORDER BY journeys_count DESC)
--     ORDER BY journeys_count DESC
--     LIMIT 5) AS top5
--     ORDER BY rank5, rank4, rank3, rank2, rank1 DESC
--     LIMIT 1
--   $function$ STABLE LANGUAGE SQL;
-- ', utils.get_api_schema(), utils.get_api_schema(), utils.get_api_schema(), utils.get_api_schema());

NOTIFY pgrst,
'reload schema';

END
$$
LANGUAGE plpgsql;

COMMIT;
