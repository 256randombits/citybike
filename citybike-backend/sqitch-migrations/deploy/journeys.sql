-- Deploy bikeapp:journeys to pg
-- requires: stations

BEGIN;

CREATE TABLE internal.journeys(
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    departure_time TIMESTAMPTZ NOT NULL,
    return_time TIMESTAMPTZ NOT NULL,
    departure_station_id INTEGER NOT NULL,
    return_station_id INTEGER NOT NULL,
    distance_in_meters INTEGER NOT NULL,
    duration_in_seconds INTEGER GENERATED ALWAYS AS (EXTRACT(EPOCH FROM return_time - departure_time)) STORED,
    CONSTRAINT not_less_than_ten_meters CHECK (distance_in_meters >= 10),
    CONSTRAINT not_less_than_ten_seconds CHECK (return_time - departure_time >= INTERVAL '10 seconds'),
    CONSTRAINT departure_station FOREIGN KEY (departure_station_id) REFERENCES internal.stations(id),
    CONSTRAINT return_station FOREIGN KEY (return_station_id) REFERENCES internal.stations(id)
);

COMMIT;

