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

-- Test adding departures count.
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
-- Test top5
BEGIN;
DO $$DECLARE
  station_id INTEGER;
  rank1_id INTEGER;
  rank2_id INTEGER;
  rank3_id INTEGER;
  rank4_id INTEGER;
  rank5_id INTEGER;
  actual_rank1 INTEGER;
  actual_rank2 INTEGER;
  actual_rank3 INTEGER;
  actual_rank4 INTEGER;
  actual_rank5 INTEGER;
BEGIN
    -- Arrange
    station_id = test_utils.create_station_and_get_id();
    rank1_id = test_utils.create_station_and_get_id();
    rank2_id = test_utils.create_station_and_get_id();
    rank3_id = test_utils.create_station_and_get_id();
    rank4_id = test_utils.create_station_and_get_id();
  -- Leave rank 5 to be null.

    FOR counter in 1..5 LOOP
      PERFORM test_utils.add_journey(station_id, rank1_id);
    END loop;

    FOR counter in 1..4 LOOP
      PERFORM test_utils.add_journey(station_id, rank2_id);
    END loop;

    FOR counter in 1..3 LOOP
      PERFORM test_utils.add_journey(station_id, rank3_id);
    END loop;

    FOR counter in 1..2 LOOP
      PERFORM test_utils.add_journey(station_id, rank4_id);
    END loop;

    -- Act
    SELECT t5d.rank1, t5d.rank2, t5d.rank3, t5d.rank4, t5d.rank5
    INTO actual_rank1, actual_rank2, actual_rank3, actual_rank4, actual_rank5
    FROM
      api.top5_destinations t5d
    WHERE
      t5d.departure_station_id = station_id;

    -- Assert
    ASSERT actual_rank1 IS NOT NULL
       AND actual_rank2 IS NOT NULL
       AND actual_rank3 IS NOT NULL
       AND actual_rank4 IS NOT NULL,
      FORMAT('Station with id %I has RANK1 %I when should be %I.'
      , station_id, actual_rank1, rank1_id);

    ASSERT rank1_id = actual_rank1,
      FORMAT('Station with id %I has RANK1 %I when should be %I.'
      , station_id, actual_rank1, rank1_id);

    ASSERT rank2_id = actual_rank2,
      FORMAT('Station with id %I has RANK2 %I when should be %I.'
      , station_id, actual_rank2, rank2_id);

    ASSERT rank3_id = actual_rank3,
      FORMAT('Station with id %I has RANK3 %I when should be %I.'
      , station_id, actual_rank3, rank3_id);

    ASSERT rank4_id = actual_rank4,
      FORMAT('Station with id %I has RANK4 %I when should be %I.'
      , station_id, actual_rank4, rank4_id);

    ASSERT rank5_id IS NULL,
      FORMAT('Station with id %I has RANK5 %I when should be %I.'
      , station_id, actual_rank1, rank1_id);
END$$;

ROLLBACK;

-- Test top5 monthly
BEGIN;
DO $$DECLARE
  station_id INTEGER;
  rank1_this_month INTEGER;
  rank1_the_other_month INTEGER;
  actual_rank1_this_month INTEGER;
  actual_rank1_the_other_month INTEGER;
  this_month_journey_start TIMESTAMPTZ = '2021-10-10T22:40:00';
  this_month_journey_end TIMESTAMPTZ = '2021-10-10T23:00:00';
  the_other_month_journey_start TIMESTAMPTZ = '2021-11-10T22:40:00';
  the_other_month_journey_end TIMESTAMPTZ = '2021-11-10T23:00:00';
BEGIN
    -- Arrange
    station_id = test_utils.create_station_and_get_id();
    rank1_this_month = test_utils.create_station_and_get_id();
    rank1_the_other_month = test_utils.create_station_and_get_id();

    -- Put less than other month's rank1
    FOR counter in 1..2 LOOP
      PERFORM test_utils.add_journey(station_id, 
        rank1_this_month,this_month_journey_start,this_month_journey_end);
    END loop;

    -- Put more than this month's rank1
    FOR counter in 1..5 LOOP
      PERFORM test_utils.add_journey(station_id, 
        rank1_the_other_month,the_other_month_journey_start,the_other_month_journey_end);
    END loop;

    -- Act
    SELECT t5dm.rank1
    INTO actual_rank1_this_month
    FROM
      api.top5_destinations_monthly t5dm
    WHERE
      t5dm.departure_station_id = station_id AND
      month_timestamp = date_trunc('month',this_month_journey_start);

    SELECT t5dm.rank1
    INTO actual_rank1_the_other_month
    FROM
      api.top5_destinations_monthly t5dm
    WHERE
      t5dm.departure_station_id = station_id AND
      month_timestamp = date_trunc('month',the_other_month_journey_start);

    -- Assert

    ASSERT rank1_this_month = actual_rank1_this_month,
      FORMAT('Station with id %I has RANK1 %I when should be %I.'
      , station_id, actual_rank1_this_month, actual_rank1_this_month);

    ASSERT rank1_the_other_month = actual_rank1_the_other_month,
      FORMAT('Station with id %I has RANK1 %I when should be %I.'
      , station_id, actual_rank1_the_other_month, actual_rank1_the_other_month);

END$$;
ROLLBACK;

