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


-- CREATE VIEW api.stats_stations AS
-- SELECT
--   departures.id AS station_id,
--   departures_count,
--   returns_count,
--   average_departure_distance_in_meters,
--   average_return_distance_in_meters
-- FROM
--   api.journeys journeys
--   FULL OUTER JOIN api.stations departures ON journeys.departure_station_id = departures.id
--   FULL OUTER JOIN api.stations returns ON journeys.return_station_id = returns.id
--   WINDOW departures_window AS (PARTITION BY station_id
--     )
COMMIT;
