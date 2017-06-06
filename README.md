This repository contains common artifacts used to build Spring guides.

The full pipeline is generated. Clone the repository, and all the
guides you want to build, in the same root directory. Then run this
script to generate a `pipeline.yml`.

```
$ ./generate.sh
$ fly --target spring login --concourse-url https://ci.spring.io --team-name spring-guides
```

Make credentials.yml containing 

```
docker-hub-email:
docker-hub-username: <user who can push to dockerhub springio>
docker-hub-password:
public-key: <public key>
private-key: <private key for signing jars>
```

And then deploy the pipeline:

```
$ fly --target spring set-pipeline --config pipeline.yml --pipeli --load-vars-from credentials.yml
`
