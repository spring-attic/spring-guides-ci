#!/bin/sh

ci/rabbit/run.sh
cd source/complete
./gradlew build -g ../.gradle
