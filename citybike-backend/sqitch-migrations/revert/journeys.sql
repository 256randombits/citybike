-- Revert bikeapp:journeys from pg

BEGIN;

DROP TABLE internal.journeys;

COMMIT;
