-- Deploy bikeapp:api_journeys to pg
-- requires: journeys
BEGIN;

-- Create view
CREATE VIEW api.journeys AS
SELECT
  id,
  departure_time,
  return_time,
  departure_station_id,
  return_station_id,
  distance_in_meters,
  duration_in_seconds
FROM
  internal.journeys;

GRANT SELECT, DELETE, INSERT ON api.journeys TO web_anon;

NOTIFY pgrst,
'reload schema';

COMMIT;
