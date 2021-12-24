# PHP Watch Docker Image

#### Version 0.0.0

A Docker image for watching files and running PHPUnit tests when files change. Uses [entr](http://eradman.com/entrproject/) to watch files, then runs [PHPUnit](https://phpunit.de/) from the PHP CLI.

## Using with Docker Compose

Craete a simple Docker Compose service:

```yaml
services:
  test:
    image: ideasonpurpose/phpunit-watch:0.0.0
    volumes:
      - ./:/app
```

Then run tests with `docker compose run test` or watch for changes with

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

The plain Docker command to run this image looks like this:

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
