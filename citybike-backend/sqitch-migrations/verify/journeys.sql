-- Verify bikeapp:journeys on pg
BEGIN;

DO $$
DECLARE
  station_id INTEGER;
  too_short_distance CONSTANT INTEGER := 9;
  long_enough_distance CONSTANT INTEGER := 10;
  too_short_duration_start CONSTANT TIMESTAMP := '2021-05-31T10:10:00';
  too_short_duration_end CONSTANT TIMESTAMP := '2021-05-31T10:10:09';
  long_enough_duration_start CONSTANT TIMESTAMP := '2021-05-31T10:10:00';
  long_enough_duration_end CONSTANT TIMESTAMP := '2021-05-31T10:10:10';
BEGIN
  -- Create a station used in tests
  INSERT INTO internal.stations(
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
  -- A type telling which contraint was hit or was any constraint hit at all.
  CREATE TYPE hit_status AS ENUM(
    'hit_distance_constraint',
    'hit_duration_constraint',
    'no_hit'
);
  -- A function that takes duration and distance and returns a boolean telling whether or not
  -- it is possible to insert a journey with the given distance or duration.
  CREATE OR REPLACE FUNCTION pg_temp.test_journey(departure TIMESTAMPTZ, RETURN TIMESTAMPTZ, distance INTEGER, station_id INTEGER )
    RETURNS hit_status AS $function$
DECLARE
  constraint_name TEXT;
  distance_constraint CONSTANT TEXT := 'not_less_than_ten_meters';
  duration_constraint CONSTANT TEXT := 'not_less_than_ten_seconds';
  hit_constraint hit_status := 'no_hit';
BEGIN
  INSERT INTO internal.journeys(
    departure_time,
    return_time,
    departure_station_id,
    return_station_id,
    distance_in_meters)
  VALUES (
    departure,
    RETURN,
    station_id,
    station_id,
    distance);
  -- When a constraint is hit this return will be jumped over.
  RETURN hit_constraint;
  EXCEPTION
    WHEN CHECK_VIOLATION THEN
      GET STACKED DIAGNOSTICS constraint_name := CONSTRAINT_NAME;
  IF constraint_name = distance_constraint THEN
    hit_constraint = 'hit_distance_constraint';
    RETURN hit_constraint;
  ELSIF constraint_name = duration_constraint THEN
    hit_constraint = 'hit_duration_constraint';
    RETURN hit_constraint;
  ELSE
    RAISE;
    END IF;
  END;

$function$
LANGUAGE plpgsql;

ASSERT(pg_temp.test_journey(too_short_duration_start, too_short_duration_end, long_enough_distance, station_id) = 'hit_duration_constraint'),
'Should fail when inserting too short duration';

ASSERT(pg_temp.test_journey(long_enough_duration_start, long_enough_duration_end, too_short_distance, station_id) = 'hit_distance_constraint'),
'Should fail when inserting too short distance.';

ASSERT(pg_temp.test_journey(long_enough_duration_start, long_enough_duration_end, long_enough_distance, station_id) = 'no_hit'),
'Should not hit a constraint when inserting long enough values.';

END
$$
LANGUAGE plpgsql;

ROLLBACK;
