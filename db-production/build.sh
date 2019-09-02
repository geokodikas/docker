#!/bin/sh

set -e
set -x

docker build -t geokodikas/production-db:latest .
docker push geokodikas/production-db:latest

