#!/bin/sh

cd /var/lib/neo4j
/docker-entrypoint.sh neo4j &
curl -v -u neo4j:neo4j -X POST localhost:7474/user/neo4j/password -H "Content-type:application/json" -d "{\"password\":\"secret\"}"
