-- Verify citybikes:journeys on pg
BEGIN;

DO $$
DECLARE
    station_id INTEGER;
    too_short_duration CONSTANT INTEGER := 9;
    too_short_distance CONSTANT INTEGER := 9;
    long_enough_duration CONSTANT INTEGER := 10;
    long_enough_distance CONSTANT INTEGER := 10;
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
        operator,
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
    -- A function that takes duration and distance and returns a boolean telling whether or not
    -- it is possible to insert a journey with the given distance or duration.
    CREATE OR REPLACE FUNCTION pg_temp.test_journey(duration INTEGER, distance INTEGER, station_id INTEGER)
        RETURNS BOOLEAN AS $function$
DECLARE
    n TEXT;
    distance_c TEXT := 'not_less_than_ten_meters';
    duration_c TEXT := 'not_less_than_ten_seconds';
    value BOOLEAN := TRUE;
BEGIN
    INSERT INTO internal.journeys(
        departure_time,
        return_time,
        departure_station_id,
        return_station_id,
        distance_in_meters,
        duration_in_seconds)
    VALUES (
        '2021-05-31T23:57:25',
        '2021-06-01T00:05:46',
        station_id,
        station_id,
        distance,
        duration);
    EXCEPTION
        WHEN CHECK_VIOLATION THEN
            GET STACKED DIAGNOSTICS n := CONSTRAINT_NAME;
             IF n = distance_c OR n = duration_c THEN
                 value = FALSE;
             ELSE
                 RAISE;
             END IF;
    RETURN value;
END $function$
LANGUAGE plpgsql;

ASSERT(pg_temp.test_journey(too_short_duration, long_enough_distance, station_id) = FALSE),'Should fail when inserting too short duration';
ASSERT(pg_temp.test_journey(long_enough_duration, too_short_distance, station_id) = FALSE),'Should fail when inserting too short distance.';

END
$$
LANGUAGE plpgsql;

ROLLBACK;

