# PHP Watch Docker Image

#### Version 0.1.5

[![dockeri.co](https://dockeri.co/image/ideasonpurpose/phpunit-watch)](https://hub.docker.com/r/ideasonpurpose/phpunit-watch)

## About This Project

This Docker watches files then runs PHPUnit tests when those files change. Files are watched with [entr](http://eradman.com/entrproject/), then tests are run with [PHPUnit](https://phpunit.de/) built on the the PHP cli base image.

## Using with Docker Compose

Create a simple Docker Compose service:

```yaml
services:
  test:
    image: ideasonpurpose/phpunit-watch:0.1.5
    volumes:
      - ./:/app
```

Then run tests with `docker compose run test` or watch for changes with `docker compose run test watch`.

### Package.json scripts

Add the following two scripts to **package.json** so the tests can be called with `npm run test` and `npm run test:watch`:

```json
{
  "scripts": {
    "test": "docker compose run --rm test",
    "test:watch": "docker compose run --rm test watch"
  }
}
```

The default working directory is `/app`, mount your project's test files there. If a project needs to mount a deeper tree, redefine `working_dir` to the test root directory.

## Basic Docker command

The Docker command to directly run this image looks like this:

```sh
docker run --rm -v "${PWD}:/app" ideasonpurpose/phpunit-watch:dev watch
```

## Coverage Reporting

To see coverage in VSCode with the [Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters) extension, add this to **settings.json** to remap the docker paths:

```json
{
  "coverage-gutters.remotePathResolve": ["/app/", "./"]
}
```

## Local Development

To iterate on this project locally, build the image using the same name as the Docker Hub remote. Docker will use the local copy. Specify `dev` if you're using using versions.

```sh
docker build . --tag ideasonpurpose/phpunit-watch:dev
```

### Repo Secrets

The GitHub actions for this project require both a DockerHub Access Token and the account password. This is due to Docker Hub not yet supporting Access Tokens for the description API (see [peter-evans/dockerhub-description#10](https://github.com/peter-evans/dockerhub-description/issues/10)).
