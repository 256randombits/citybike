-- Verify bikeapp:api_stations on pg
BEGIN;

-- Become web_anon for the duration of this tranaction.
SET LOCAL ROLE web_anon;

-- Just try to do everything.
-- If it fails, it fails.
DO $$
DECLARE
  insertion_id INTEGER;
BEGIN
  -- Insert
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
  id INTO insertion_id;
  -- SELECT
  PERFORM
    name_fi
  FROM
    api.stations
  WHERE
    id = insertion_id;
  -- DELETE
  DELETE FROM api.stations
  WHERE id = insertion_id;
END
$$;

ROLLBACK;
