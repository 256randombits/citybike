#!/bin/bash

# https://github.com/docker-library/docs/blob/master/postgres/README.md#initialization-scripts
set -e

# PostgREST will exit if it can not login.
psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" --port "${POSTGRES_PORT}"<<-EOSQL
	CREATE ROLE ${PGRST_DB_AUTH_ROLE} NOINHERIT LOGIN PASSWORD '${PGRST_DB_AUTH_PASSWORD}';
EOSQL
