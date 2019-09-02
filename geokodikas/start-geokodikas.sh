#!/usr/bin/env bash

set -e
set -x

/opt/wait-for -t 60 "$GEOKODIKAS_DB_HOST:$GEOKODIKAS_DB_PORT" -- java -jar rest-api-jar-with-dependencies.jar

