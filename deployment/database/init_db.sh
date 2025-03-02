#!/bin/bash
set -e

# Firstly, create users and grant privileges
# Then create databases: one for wideworldimporters and one for prefect
PGPASSWORD=${POSTGRES_PASSWORD} psql -v ON_ERROR_STOP=1 --username ${POSTGRES_USER} --dbname ${POSTGRES_DB} <<-EOSQL
	  CREATE DATABASE prefect;
EOSQL
