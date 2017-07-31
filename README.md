## What and why?

Sometimes you need to put some secret files inside docker image.  
One example is CI that can use secret variables but can't use secret files
(hello [GitLab](https://gitlab.com)). 
With `docker-secret-files` you can protect such files with encryption.  

Idea is very simple:
1. Encrypt files with GPG, protect them with password and place inside docker
image.
2. At any time you can decrypt files from image with password and save to local
filesystem or use them in CI pipeline. All tools for encryption is built-in.

Files encrypted with default GPG symmetric cipher (AES-128 now). It is strong
enough (of course, if you are not going to play with NSA 😉). 

Resulting image based on [Alpine Linux](https://hub.docker.com/_/alpine/)
and very small (16MB, ~7MB compressed).

## Building image

**You must build this image with `--squash` option only!**

Otherwise intermediate layers will contain secret files. `./secret.sh` will do
it for you.  
Squashing is experimental feature for now (docker 17.06.0) so docker daemon
should be started with `--experimental=true` flag (building only).

1. put secret files inside `secret/`
2. `./secret.sh -c pAssW0rd`

```bash
$ ./secret.sh -c [-i image-name] [-p] pAssW0rd

  -c: create image
  -i: image name ('secret' is default)
  -p: push image
```

## Decrypting files

### To local filesystem.

`./secret.sh -d pAssW0rd`

```bash
$ ./secret.sh -d [-i image-name] [-o out-secret] pAssW0rd

  -d: decrypt and get out secret files
  -i: image name ('secret' is default)
  -o: output dir ('dsecret' is default)
```

### Inside container

`decrypt ./decrypted/ pAssW0rd`

## Using with gitlab-ci

```yaml
# fix issue https://gitlab.com/gitlab-org/gitlab-ce/issues/18214
variables:
  SECRET_PASSWORD: $SECRET_PASSWORD

services:
  - image: registry.gitlab.com/secret-image
    entrypoint: [sh, -c, decrypt /builds/$CI_PROJECT_NAMESPACE/secrets $SECRET_PASSWORD]

build:
  image: busybox
  script:
    - ls -la /builds/$CI_PROJECT_NAMESPACE/secrets
```

Log will show warning about failing to link container. Image do not expose any
ports so it's ok. Just ignore it.
