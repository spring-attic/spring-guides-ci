#!/bin/sh

ci/mongo/run.sh
cd source/complete
./gradlew build -g ../.gradle
