-- Verify bikeapp:stations on pg
BEGIN;

-- Can insert a station with all the values.
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
  60.16582);

-- Can insert a station without the Engish name.
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
  NULL,
  'Hanasaarenranta 1',
  'Hanaholmsstranden 1',
  'Espoo',
  'Esbo',
  'CityBike Finland',
  10,
  24.840319,
  60.16582);

-- Test that a null name can't be inserted.
DO $$
BEGIN
  INSERT INTO internal.stations(
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
  VALUES(
    'Hanaholmen',
    NULL,
    'Hanasaarenranta 1',
    'Hanaholmsstranden 1',
    'Espoo',
    'Esbo',
    'CityBike Finland',
    10,
    24.840319,
    60.16582);
  -- This will be jumped over when the error happens.
  RAISE EXCEPTION 'Name should not be allowed to be null!';
  EXCEPTION
    WHEN not_null_violation THEN
      -- Do nothing
END
$$ LANGUAGE plpgsql;

ROLLBACK;
