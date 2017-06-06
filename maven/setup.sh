#!/bin/sh

if ! [ -z "${PRIVATE_KEY}" ]; then
    echo "${PRIVATE_KEY}" > private.key
fi

cp -rf source ci/maven/* private.key build/maven
