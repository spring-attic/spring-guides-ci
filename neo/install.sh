#!/bin/sh

ci/neo/run.sh
cd source/complete
./mvnw install
