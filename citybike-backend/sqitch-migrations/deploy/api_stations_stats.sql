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

CREATE VIEW api.top5_destinations AS
  SELECT DISTINCT * 
  FROM 
    (SELECT *
     FROM
      (SELECT

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
  				            UNBOUNDED FOLLOWING)
  	  ORDER BY journeys_count DESC) AS top5
    ) AS idk
  ORDER BY departure_station_id;
COMMIT;
