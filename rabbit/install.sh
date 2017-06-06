#!/bin/sh

ci/rabbit/run.sh
cd source/complete
./mvnw install
