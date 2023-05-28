-- Revert bikeapp:api_data_import from pg

BEGIN;

DROP FUNCTION api.station_import(id INTEGER, name_fi VARCHAR(64), name_sv VARCHAR(64), name_en VARCHAR(64), address_fi VARCHAR(64), address_sv VARCHAR(64), city_fi VARCHAR(64), city_sv VARCHAR(64), operator VARCHAR(64), capacity INTEGER, longitude FLOAT, latitude FLOAT);
ALTER TABLE internal.stations
DROP COLUMN id_in_avoindata;

COMMIT;
