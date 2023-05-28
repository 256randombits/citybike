-- Verify bikeapp:api_journeys on pg

BEGIN;

-- Become web_anon for the duration of this tranaction.
SET LOCAL ROLE web_anon;

-- Just try to do everything.
-- If it fails, it fails.
DO $$
DECLARE
  station_id INTEGER;
  insertion_id INTEGER;
  long_enough_distance CONSTANT INTEGER := 10;
  long_enough_duration_start CONSTANT TIMESTAMP := '2021-05-31T10:10:00';
  long_enough_duration_end CONSTANT TIMESTAMP := '2021-05-31T10:10:10';
BEGIN
  -- Create a station
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
    'Hanasaari',
    'Hanaholmen',
    'Hanasaari',
    'Hanasaarenranta 1',
    'Hanaholmsstranden 1',
    'Espoo',
    'Esbo',
    'CityBike Finland',
    10,
    24.840319,
    60.16582)
RETURNING
  id INTO station_id;

  -- Insert
  INSERT INTO api.journeys(
    departure_time,
    return_time,
    departure_station_id,
    return_station_id,
    distance_in_meters)
  VALUES (
    long_enough_duration_start,
    long_enough_duration_end,
    station_id,
    station_id,
    long_enough_distance) RETURNING id INTO insertion_id;
  -- Select
  PERFORM
    departure_time
  FROM
    api.journeys
  WHERE
    id = insertion_id;
  -- DELETE
  DELETE FROM api.journeys
  WHERE id = insertion_id;
 
END
$$;

ROLLBACK;
