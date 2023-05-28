-- Deploy bikeapp:api_data_import to pg
-- requires: journeys
BEGIN;

ALTER TABLE internal.stations
ADD COLUMN id_in_avoindata INTEGER UNIQUE;

CREATE FUNCTION api.station_import(id INTEGER, name_fi VARCHAR(64), name_sv VARCHAR(64), name_en VARCHAR(64), address_fi VARCHAR(64), address_sv VARCHAR(64), city_fi VARCHAR(64), city_sv VARCHAR(64), operator VARCHAR(64), capacity INTEGER, longitude FLOAT, latitude FLOAT)
RETURNS void AS $$
DECLARE
  id_here INTEGER;
BEGIN

  INSERT INTO internal.stations(
    id_in_avoindata,
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
    id,
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
    latitude);

END;
$$ LANGUAGE plpgsql;

-- Permissions
GRANT EXECUTE ON FUNCTION api.station_import(id INTEGER, name_fi VARCHAR(64), name_sv VARCHAR(64), name_en VARCHAR(64), address_fi VARCHAR(64), address_sv VARCHAR(64), city_fi VARCHAR(64), city_sv VARCHAR(64), operator VARCHAR(64), capacity INTEGER, longitude FLOAT, latitude FLOAT) TO web_anon;

NOTIFY pgrst,
'reload schema';

COMMIT;
