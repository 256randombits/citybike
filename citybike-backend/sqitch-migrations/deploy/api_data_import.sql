-- Deploy bikeapp:api_data_import to pg
-- requires: journeys
BEGIN;

CREATE FUNCTION api.journey_import(departure_time TIMESTAMPTZ, return_time TIMESTAMPTZ, departure_station_id INTEGER, return_station_id INTEGER, distance_in_meters INTEGER)
  RETURNS void
  AS $$
DECLARE
  departure_station_id_here INTEGER;
  return_station_id_here INTEGER;
BEGIN
  -- departure_station_id_here
  SELECT
    id
  FROM
    api.stations
  WHERE
    id_in_avoindata = departure_station_id INTO departure_station_id_here;
  -- return_station_id_here
  SELECT
    id
  FROM
    api.stations
  WHERE
    id_in_avoindata = return_station_id INTO return_station_id_here;
  -- Insert
  INSERT INTO api.journeys(
    departure_time,
    return_time,
    departure_station_id,
    return_station_id,
    distance_in_meters)
  VALUES (
    departure_time,
    return_time,
    departure_station_id_here,
    return_station_id_here,
    distance_in_meters);

  END;
$$
LANGUAGE plpgsql;

-- Permissions
GRANT EXECUTE ON FUNCTION api.journey_import(departure_time TIMESTAMPTZ, return_time TIMESTAMPTZ, departure_station_id INTEGER, return_station_id INTEGER, distance_in_meters INTEGER) to web_anon;

NOTIFY pgrst,
'reload schema';

COMMIT;
