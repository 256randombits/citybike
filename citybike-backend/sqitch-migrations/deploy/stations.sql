-- Deploy bikeapp:stations to pg

BEGIN;

CREATE SCHEMA internal;

CREATE TABLE internal.stations(
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name_fi VARCHAR(64) NOT NULL,
    name_sv VARCHAR(64) NOT NULL,
    name_en VARCHAR(64),
    address_fi VARCHAR(64) NOT NULL,
    address_sv VARCHAR(64) NOT NULL,
    city_fi VARCHAR(64) NOT NULL,
    city_sv VARCHAR(64) NOT NULL,
    operator VARCHAR(64) NOT NULL,
    capacity INTEGER NOT NULL,
    longitude FLOAT NOT NULL,
    latitude FLOAT NOT NULL
);

COMMIT;
