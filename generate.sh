#!/bin/bash

# Use this script to generate a pipeline for getting started
# guides. Clone the repository, and all the guides you want to build,
# in the same root directory. Then run this script to generate a
# pipeline.yml.

output=pipeline.yml;
mavens=();
rabbits=();
mongos=();
neos=();
gradles=();

function project() {
    echo $1 | sed -e 's,../,,' -e 's,/complete,,'
}

cat > $output <<EOF
# fly --target spring login --concourse-url https://ci.spring.io
# fly --target spring set-pipeline --config pipeline.yml --pipeline spring-guides-ci --load-vars-from credentials.yml
---
resources:
- name: image-source
  type: git
  source:
    uri: https://github.com/spring-guides/gs-rest-service.git
    paths: [complete/pom.xml, complete/build.gradle]
- name: ci
  type: git
  source:
    uri: https://github.com/spring-guides/spring-guides-ci.git
- name: base-image
  type: docker-image
  source:
    email: {{docker-hub-email}}
    username: {{docker-hub-username}}
    password: {{docker-hub-password}}
    repository: springio/spring-ci-base
- name: rabbit-base-image
  type: docker-image
  source:
    email: {{docker-hub-email}}
    username: {{docker-hub-username}}
    password: {{docker-hub-password}}
    repository: springio/spring-rabbit-base
- name: mongo-base-image
  type: docker-image
  source:
    email: {{docker-hub-email}}
    username: {{docker-hub-username}}
    password: {{docker-hub-password}}
    repository: springio/spring-mongo-base
- name: neo-base-image
  type: docker-image
  source:
    email: {{docker-hub-email}}
    username: {{docker-hub-username}}
    password: {{docker-hub-password}}
    repository: springio/spring-neo-base
- name: openjdk:8-jdk
  type: docker-image
  source:
    repository: openjdk
    tag:        8-jdk
- name: neo4j
  type: docker-image
  source:
    repository: neo4j
- name: rabbitmq:management
  type: docker-image
  source:
    repository: rabbitmq
    tag:        management
EOF

for f in `find ../gs-* -name complete -type d | sort`; do
    if [ -e $f/pom.xml -o -e $f/build.gradle ]; then
        project=$(project $f);
        cat >> $output <<EOF
- name: $project
  type: git
  source:
    uri: https://github.com/spring-guides/$project.git
EOF
    fi
done

cat >> $output <<EOF

jobs:
- name: image
  public: true
  serial: true
  plan:
  - aggregate:
    - get: ci
      trigger: true
    - get: image-source
      trigger: true
    - get: openjdk:8-jdk
      trigger: true
  - task: setup
    file: ci/image/setup.yml
    input_mapping:
      source: image-source
    params:
      PUBLIC_KEY: {{public-key}}
      PRIVATE_KEY: {{private-key}}
  - put: base-image
    params:
      build: build/image
- name: rabbit-image
  public: true
  serial: true
  plan:
  - aggregate:
    - get: ci
      trigger: true
    - get: image-source
      trigger: true
    - get: rabbitmq:management
      trigger: true
  - task: setup
    file: ci/image/setup.yml
    input_mapping:
      source: image-source
    params:
      PUBLIC_KEY: {{public-key}}
      PRIVATE_KEY: {{private-key}}
  - put: rabbit-base-image
    params:
      build: ci/rabbit
- name: mongo-image
  public: true
  serial: true
  plan:
  - aggregate:
    - get: ci
      trigger: true
    - get: image-source
      trigger: true
    - get: openjdk:8-jdk
      trigger: true
  - task: setup
    file: ci/image/setup.yml
    input_mapping:
      source: image-source
    params:
      PUBLIC_KEY: {{public-key}}
      PRIVATE_KEY: {{private-key}}
  - put: mongo-base-image
    params:
      build: ci/mongo

- name: neo-image
  public: true
  serial: true
  plan:
  - aggregate:
    - get: ci
      trigger: true
    - get: image-source
      trigger: true
    - get: neo4j
      trigger: true
  - task: setup
    file: ci/image/setup.yml
    input_mapping:
      source: image-source
    params:
      PUBLIC_KEY: {{public-key}}
      PRIVATE_KEY: {{private-key}}
  - put: neo-base-image
    params:
      build: ci/neo

EOF

for f in `find ../gs-* -name complete -type d | sort`; do
    project=$(project $f)
    if echo ${project} | grep -q rabbit; then
        rabbits+=(${project});
    elif echo ${project} | grep -q mongo; then
        mongos+=(${project});
    elif echo ${project} | grep -q neo4j; then
        neos+=(${project});
    else
        if [ -e $f/pom.xml ]; then
            mavens+=(${project});
        fi
        if [ -e $f/build.gradle ]; then
            gradles+=(${project});
        fi
    fi
done

for project in "${mavens[@]}"; do
  cat >> $output <<EOF
- name: ${project}-maven
  plan:
  - aggregate:
    - get: ci
    - get: $project
      trigger: true
    - get: base-image
      trigger: true
      passed: [image]
  - task: maven
    file: ci/tasks/install.yml
    image: base-image
    input_mapping:
      source: $project

EOF
done
for project in "${gradles[@]}"; do
  cat >> $output <<EOF
- name: ${project}-gradle
  plan:
  - aggregate:
    - get: ci
    - get: $project
      trigger: true
    - get: base-image
      trigger: true
      passed: [image]
  - task: gradle
    file: ci/tasks/build.yml
    image: base-image
    input_mapping:
      source: $project

EOF
done
for project in "${rabbits[@]}"; do
  cat >> $output <<EOF
- name: ${project}-maven
  plan:
  - aggregate:
    - get: ci
    - get: $project
      trigger: true
    - get: rabbit-base-image
      trigger: true
      passed: [rabbit-image]
  - task: maven
    file: ci/rabbit/install.yml
    image: rabbit-base-image
    input_mapping:
      source: $project
- name: ${project}-gradle
  plan:
  - aggregate:
    - get: ci
    - get: $project
      trigger: true
    - get: rabbit-base-image
      trigger: true
      passed: [rabbit-image]
  - task: gradle
    file: ci/rabbit/build.yml
    image: rabbit-base-image
    input_mapping:
      source: $project

EOF
done
for project in "${mongos[@]}"; do
  cat >> $output <<EOF
- name: ${project}-maven
  plan:
  - aggregate:
    - get: ci
    - get: $project
      trigger: true
    - get: mongo-base-image
      trigger: true
      passed: [mongo-image]
  - task: maven
    file: ci/mongo/install.yml
    image: mongo-base-image
    input_mapping:
      source: $project
- name: ${project}-gradle
  plan:
  - aggregate:
    - get: ci
    - get: $project
      trigger: true
    - get: mongo-base-image
      trigger: true
      passed: [mongo-image]
  - task: gradle
    file: ci/mongo/build.yml
    image: mongo-base-image
    input_mapping:
      source: $project

EOF
done
for project in "${neos[@]}"; do
  cat >> $output <<EOF
- name: ${project}-maven
  plan:
  - aggregate:
    - get: ci
    - get: $project
      trigger: true
    - get: neo-base-image
      trigger: true
      passed: [neo-image]
  - task: maven
    file: ci/neo/install.yml
    image: neo-base-image
    input_mapping:
      source: $project
- name: ${project}-gradle
  plan:
  - aggregate:
    - get: ci
    - get: $project
      trigger: true
    - get: neo-base-image
      trigger: true
      passed: [neo-image]
  - task: gradle
    file: ci/neo/build.yml
    image: neo-base-image
    input_mapping:
      source: $project

EOF
done

cat >> $output <<EOF
groups:
- name: all
  jobs:
  - image
  - rabbit-image
  - mongo-image
  - neo-image
EOF
for project in "${mavens[@]}"; do
    echo >> $output "  - "${project}"-maven"
done
for project in "${gradles[@]}"; do
    echo >> $output "  - "${project}"-gradle"
done
for project in "${rabbits[@]}"; do
    echo >> $output "  - "${project}"-maven"
    echo >> $output "  - "${project}"-gradle"
done
for project in "${mongos[@]}"; do
    echo >> $output "  - "${project}"-maven"
    echo >> $output "  - "${project}"-gradle"
done
for project in "${neos[@]}"; do
    echo >> $output "  - "${project}"-maven"
    echo >> $output "  - "${project}"-gradle"
done
cat >> $output <<EOF
- name: images
  jobs:
  - image
  - rabbit-image
  - mongo-image
  - neo-image
- name: maven
  jobs:
EOF
for project in "${mavens[@]}"; do
    echo >> $output "  - "${project}"-maven"
done
for project in "${rabbits[@]}"; do
    echo >> $output "  - "${project}"-maven"
done
for project in "${mongos[@]}"; do
    echo >> $output "  - "${project}"-maven"
done
for project in "${neos[@]}"; do
    echo >> $output "  - "${project}"-maven"
done
cat >> $output <<EOF
- name: gradle
  jobs:
EOF
for project in "${gradles[@]}"; do
    echo >> $output "  - "${project}"-gradle"
done
for project in "${rabbits[@]}"; do
    echo >> $output "  - "${project}"-gradle"
done
for project in "${mongos[@]}"; do
    echo >> $output "  - "${project}"-gradle"
done
for project in "${neos[@]}"; do
    echo >> $output "  - "${project}"-gradle"
done
cat >> $output <<EOF
- name: rabbit
  jobs:
EOF
for project in "${rabbits[@]}"; do
    echo >> $output "  - "${project}"-maven"
    echo >> $output "  - "${project}"-gradle"
done
cat >> $output <<EOF
- name: mongo
  jobs:
EOF
for project in "${mongos[@]}"; do
    echo >> $output "  - "${project}"-maven"
    echo >> $output "  - "${project}"-gradle"
done
cat >> $output <<EOF
- name: neo
  jobs:
EOF
for project in "${neos[@]}"; do
    echo >> $output "  - "${project}"-maven"
    echo >> $output "  - "${project}"-gradle"
done

