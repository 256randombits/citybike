-- Revert citybikes:stations from pg
BEGIN;

DROP TABLE internal.stations;

DROP SCHEMA internal;

COMMIT;

