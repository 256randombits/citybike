-- Deploy bikeapp:api_stations to pg
-- requires: stations
BEGIN;

CREATE VIEW api.stations AS
SELECT
  id,
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
  latitude
FROM
  internal.stations;

-- Permissions
GRANT SELECT, DELETE, INSERT ON api.stations TO web_anon;

NOTIFY pgrst,
'reload schema';

COMMIT;
