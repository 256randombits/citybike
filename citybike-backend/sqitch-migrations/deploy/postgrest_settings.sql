-- Deploy citybikes:postgrest_settings to pg

BEGIN;

CREATE SCHEMA utils;

CREATE FUNCTION utils.get_anon_role()
RETURNS TEXT
AS $$
BEGIN
  RETURN(SELECT current_setting('pgrst.anon_role'));
END;

$$ LANGUAGE plpgsql;
CREATE FUNCTION utils.get_auth_role()
RETURNS TEXT
AS $$
BEGIN
  RETURN(SELECT current_setting('pgrst.auth_role'));
END;

$$ LANGUAGE plpgsql;
CREATE FUNCTION utils.get_api_schema()
RETURNS TEXT
AS $$
BEGIN
  RETURN(SELECT current_setting('pgrst.api_schema'));
END;
$$ LANGUAGE plpgsql;

COMMIT;
