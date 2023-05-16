-- Verify citybikes:stations on pg
BEGIN;

DO $$
BEGIN
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
    VALUES(
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
    VALUES(
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
END
$$;

ROLLBACK;

