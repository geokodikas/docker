#!/usr/bin/env bash

set -e
set -x

echo "Starting JAR..."
# TODO allow to override these options
java -XX:InitialRAMPercentage=25 -XX:MaxRAMPercentage=75 -XX:+UseContainerSupport -jar export-manager-jar-with-dependencies.jar


