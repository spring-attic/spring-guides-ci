#!/bin/sh

ci/neo/run.sh
cd source/complete
./mvnw install -Dmaven.local.repo=../.m2
