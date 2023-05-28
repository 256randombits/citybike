-- Revert bikeapp:api_journeys from pg

BEGIN;

DROP VIEW api.journeys;

COMMIT;
