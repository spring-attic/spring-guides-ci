#!/bin/sh

ci/mongo/run.sh
cd source/complete
./mvnw install
