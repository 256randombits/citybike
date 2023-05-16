-- Revert citybikes:journeys from pg

BEGIN;

DROP TABLE internal.journeys;

COMMIT;
