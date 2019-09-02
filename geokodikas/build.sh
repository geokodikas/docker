#!/bin/sh

set -e
set -x

docker build -t geokodikas/geokodikas:master .
docker push geokodikas/geokodikas:master

