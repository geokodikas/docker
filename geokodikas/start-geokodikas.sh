#!/usr/bin/env bash

set -e
set -x

echo "Starting geokodikas JAR..."
cat config.json
# TODO allow to override these options
java -XX:InitialRAMPercentage=25 -XX:MaxRAMPercentage=75 -XX:+UseContainerSupport -jar rest-api-jar-with-dependencies.jar


