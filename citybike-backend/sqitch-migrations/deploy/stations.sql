-- Deploy bikeapp:stations to pg

BEGIN;

CREATE SCHEMA internal;

CREATE TABLE internal.stations(
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name_fi VARCHAR(64) NOT NULL UNIQUE,
    name_sv VARCHAR(64) NOT NULL UNIQUE,
    name_en VARCHAR(64) UNIQUE,
    address_fi VARCHAR(64) NOT NULL,
    address_sv VARCHAR(64) NOT NULL,
    city_fi VARCHAR(64) NOT NULL,
    city_sv VARCHAR(64) NOT NULL,
    operator VARCHAR(64) NOT NULL,
    capacity INTEGER NOT NULL,
    longitude FLOAT NOT NULL,
    latitude FLOAT NOT NULL,
    id_in_avoindata INTEGER UNIQUE,
    UNIQUE(address_fi, city_fi),
    UNIQUE(address_sv, city_sv)
);

COMMIT;
