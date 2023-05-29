-- Deploy bikeapp:test_utils to pg
-- requires: api_stations
-- requires: api_journeys
BEGIN;

CREATE SCHEMA test_utils;

SET search_path TO test_utils;

-- Create a function for creating stations and getting the id back.
CREATE FUNCTION create_station_and_get_id()
  RETURNS INTEGER
  LANGUAGE plpgsql
  -- SET LOCAL SEED TO 0.2
  AS $create_station$
DECLARE
  station_id INTEGER;
  random_text TEXT;
BEGIN
  -- Avoid clashing by creating just some random string.
  SELECT
    MD5(RANDOM()::TEXT) INTO random_text;
  -- Create the station.
  INSERT INTO api.stations(
    name_fi,
    name_sv,
    name_en,
    address_fi,
    address_sv,
    city_fi,
    city_sv,
    OPERATOR,
    capacity,
    longitude,
    latitude)
  VALUES (
    random_text,
    random_text,
    random_text,
    random_text,
    random_text,
    random_text,
    random_text,
    random_text,
    100,
    100.0,
    100.0)
RETURNING
  id INTO station_id;
  RETURN station_id;
END;
$create_station$;

-- A function for adding journeys between stations with just ids.
CREATE FUNCTION add_journey(departure_station_id INTEGER, return_station_id INTEGER)
  RETURNS void
  LANGUAGE plpgsql
  AS $add_journey$
BEGIN
  -- Create the journey.
  INSERT INTO api.journeys(
    departure_station_id,
    return_station_id,
    distance_in_meters,
    departure_time,
    return_time)
  VALUES(
    departure_station_id,
    return_station_id,
    10,
    '2021-05-31T23:40:00',
    '2021-05-31T23:50:00');
END;
$add_journey$;

-- Create a function for adding journeys between stations with just ids and timestamps.
CREATE FUNCTION add_journey(departure_station_id INTEGER, return_station_id INTEGER, departure_time TIMESTAMPTZ, return_time TIMESTAMPTZ)
  RETURNS void
  LANGUAGE plpgsql
  AS $add_journey_month$
BEGIN
  -- Create the journey.
  INSERT INTO api.journeys(
    departure_station_id,
    return_station_id,
    distance_in_meters,
    departure_time,
    return_time)
  VALUES(
    departure_station_id,
    return_station_id,
    100,
    departure_time,
    return_time);
END;
$add_journey_month$;

-- Create a function for adding journeys between stations with just ids and length.
CREATE FUNCTION add_journey(departure_station_id INTEGER, return_station_id INTEGER, distance_in_meters INTEGER)
  RETURNS void
  LANGUAGE plpgsql
  AS $add_journey_length$
BEGIN
  -- Create the journey.
  INSERT INTO api.journeys(
    departure_station_id,
    return_station_id,
    distance_in_meters,
    departure_time,
    return_time)
  VALUES(
    departure_station_id,
    return_station_id,
    distance_in_meters,
    '2021-05-31T23:40:00',
    '2021-05-31T23:50:00');
END;
$add_journey_length$;

SET search_path TO public;

COMMIT;
