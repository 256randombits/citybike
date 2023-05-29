-- Verify bikeapp:api_stations_stats on pg

-- Test initial departures count.
BEGIN;
DO $$DECLARE
  dep_id INTEGER;
  ret_id INTEGER;
  departures_count INTEGER;
  should_be INTEGER;
BEGIN
    -- Arrange
    dep_id = test_utils.create_station_and_get_id();
    ret_id = test_utils.create_station_and_get_id();
    should_be = 0;
    -- Act
    SELECT
      sd.departures_count
    INTO departures_count
    FROM
      api.stats_departures_monthly sd
    WHERE
      sd.station_id = dep_id;
    -- Assert
    ASSERT departures_count = should_be,
      FORMAT(
        'Station with id %I has DEPARTURES_COUNT %I when should be %I.'
        , dep_id, departures_count, should_be);
END$$;

ROLLBACK;

-- Test initial departures count.
BEGIN;
DO $$DECLARE
  dep_id INTEGER;
  other_id INTEGER;
  departures_count INTEGER;
  should_be INTEGER;
BEGIN
    -- Arrange
    dep_id = test_utils.create_station_and_get_id();
    other_id = test_utils.create_station_and_get_id();
    PERFORM test_utils.add_journey(dep_id, other_id);
    PERFORM test_utils.add_journey(dep_id, dep_id); --Return to self.
    should_be = 2;
    -- Act
    SELECT
      sd.departures_count
    INTO departures_count
    FROM
      api.stats_departures_monthly sd
    WHERE
      sd.station_id = dep_id;
    -- Assert
    ASSERT departures_count = should_be,
    FORMAT('Station with id %I has DEPARTURES_COUNT %I when should be %I.', dep_id, departures_count, should_be);

END$$;

ROLLBACK;
