-- Revert citybikes:api_journeys from pg

BEGIN;

DO $$
BEGIN
    EXECUTE FORMAT('
        DROP VIEW %I.journeys;', utils.get_api_schema());
END
$$;

COMMIT;
