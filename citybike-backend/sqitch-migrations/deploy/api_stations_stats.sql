-- Deploy bikeapp:api_stations_stats to pg
-- requires: api_stations
-- requires: api_journeys
BEGIN;

CREATE VIEW api.stats_departures_monthly AS
  SELECT
    s_dep.id AS station_id,
    COUNT(j.return_station_id) AS departures_count,
    COALESCE(AVG(j.distance_in_meters),0.0) AS average_distance_in_meters,
    date_trunc('month', j.departure_time) month_timestamp
  FROM api.stations s_dep
    LEFT OUTER JOIN api.journeys j
      ON j.departure_station_id = s_dep.id
  GROUP BY station_id, month_timestamp;

CREATE VIEW api.stats_departures AS
  SELECT
    station_id,
    SUM(departures_count) AS departures_count,
    AVG(average_distance_in_meters) AS average_distance_in_meters
  FROM api.stats_departures_monthly

  GROUP BY station_id;

CREATE VIEW api.journeys_from_station_to_station_monthly AS
  SELECT
    s_dep.id AS departure_station_id,
    s_ret.id AS return_station_id,
    COUNT(j.return_station_id) AS journeys_count,
    date_trunc('month', j.departure_time) month_timestamp
  FROM api.stations s_dep
    FULL OUTER JOIN api.journeys j
      ON j.departure_station_id = s_dep.id
    FULL OUTER JOIN api.stations s_ret 
      ON return_station_id = s_ret.id
  GROUP BY s_dep.id, s_ret.id, month_timestamp;

CREATE VIEW api.journeys_from_station_to_station AS
  SELECT
    departure_station_id,
    return_station_id,
    SUM(journeys_count) AS journeys_count
  FROM api.journeys_from_station_to_station_monthly
  GROUP BY departure_station_id, return_station_id;

CREATE VIEW api.top5_destinations_monthly AS
  SELECT DISTINCT ON (departure_station_id, month_timestamp) 
          departure_station_id,
          month_timestamp,
    		  nth_value(return_station_id, 1) OVER w rank1, 
    		  nth_value(return_station_id, 2) OVER w rank2, 
    		  nth_value(return_station_id, 3) OVER w rank3, 
    		  nth_value(return_station_id, 4) OVER w rank4, 
    		  nth_value(return_station_id, 5) OVER w rank5
  
    	  FROM api.journeys_from_station_to_station_monthly
    	  WINDOW w AS (PARTITION BY departure_station_id, month_timestamp
    				            ORDER BY journeys_count DESC
    				            RANGE BETWEEN UNBOUNDED PRECEDING AND
    				            UNBOUNDED FOLLOWING);

CREATE VIEW api.top5_destinations AS
  SELECT DISTINCT ON (departure_station_id)
          departure_station_id,
    		  nth_value(return_station_id, 1) OVER w rank1, 
    		  nth_value(return_station_id, 2) OVER w rank2, 
    		  nth_value(return_station_id, 3) OVER w rank3, 
    		  nth_value(return_station_id, 4) OVER w rank4, 
    		  nth_value(return_station_id, 5) OVER w rank5
    	  FROM api.journeys_from_station_to_station
    	  WINDOW w AS (PARTITION BY departure_station_id 
    				            ORDER BY journeys_count DESC
    				            RANGE BETWEEN UNBOUNDED PRECEDING AND
    				            UNBOUNDED FOLLOWING);

CREATE VIEW api.stats_station_monthly AS
  SELECT 
    sdm.station_id AS station_id,
    sdm.departures_count AS departures_count,
    sdm.average_distance_in_meters AS average_distance_in_meters,
    sdm.month_timestamp AS month_timestamp
  FROM api.stats_departures_monthly sdm;

  CREATE FUNCTION api.stats_monthly(api.stations) RETURNS SETOF api.stats_station_monthly AS $function$
    SELECT * FROM api.stats_station_monthly WHERE station_id = $1.id
  $function$ STABLE LANGUAGE SQL;

-- Computed relationship
-- Allow top5 destinations in the monthly_stats
CREATE FUNCTION api.top5_destinations(api.stats_station_monthly)
  RETURNS SETOF api.top5_destinations_monthly ROWS 1 AS $$
    SELECT departure_station_id, month_timestamp, rank1, rank2, rank3, rank4, rank5
    FROM api.top5_destinations_monthly t5dm
    WHERE t5dm.departure_station_id = $1.station_id
    AND t5dm.month_timestamp = $1.month_timestamp
$$ LANGUAGE SQL;

DO $$
DECLARE
BEGIN
-- Computed/Virtual columns to put stations into the response.
FOR counter in 1..5 LOOP
  EXECUTE FORMAT(
    'CREATE FUNCTION api.rank%s_destination(api.top5_destinations_monthly) 
      RETURNS SETOF api.stations ROWS 1 AS $function$
        SELECT * FROM api.stations WHERE id = $1.rank%s
      $function$ STABLE LANGUAGE SQL;
    ', counter, counter);
END loop;
END$$;

CREATE VIEW api.stats_station AS
  SELECT 
    sd.station_id AS station_id,
    sd.departures_count AS departures_count,
    sd.average_distance_in_meters AS average_distance_in_meters
  FROM api.stats_departures sd;

  CREATE FUNCTION api.stats(api.stations) RETURNS SETOF api.stats_station AS $function$
    SELECT * FROM api.stats_station WHERE station_id = $1.id
  $function$ STABLE LANGUAGE SQL;

CREATE FUNCTION api.top5_destinations(api.stats_station)
  RETURNS SETOF api.top5_destinations ROWS 1 AS $$
    SELECT departure_station_id, rank1, rank2, rank3, rank4, rank5
    FROM api.top5_destinations t5d
    WHERE t5d.departure_station_id = $1.station_id
$$ LANGUAGE SQL;

DO $$
DECLARE
BEGIN
-- Computed/Virtual columns to put stations into the response.
FOR counter in 1..5 LOOP
  EXECUTE FORMAT(
    'CREATE FUNCTION api.rank%s_destination(api.top5_destinations) 
      RETURNS SETOF api.stations ROWS 1 AS $function$
        SELECT * FROM api.stations WHERE id = $1.rank%s
      $function$ STABLE LANGUAGE SQL;
    ', counter, counter);
END loop;
END$$;


-- Permissions
GRANT SELECT ON api.stats_station_monthly TO web_anon;
GRANT SELECT ON api.top5_destinations_monthly TO web_anon;
GRANT SELECT ON api.stats_station TO web_anon;
GRANT SELECT ON api.top5_destinations TO web_anon;

NOTIFY pgrst,
'reload schema';

COMMIT;
