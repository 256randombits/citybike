-- Revert citybikes:test from pg

BEGIN;

DROP TABLE test;

COMMIT;
