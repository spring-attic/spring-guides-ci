#!/bin/sh

ci/neo/run.sh
cd source/complete
./gradlew build -g ../.gradle
