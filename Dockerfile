# https://hub.docker.com/_/php
# https://github.com/docker-library/docs/blob/master/php/README.md#supported-tags-and-respective-dockerfile-links
FROM php:8.4.3-cli

# https://pecl.php.net/package/xdebug
RUN pecl install xdebug-3.4.1 \
    && docker-php-ext-enable xdebug \
    && echo 'xdebug.mode=coverage' > /usr/local/etc/php/conf.d/xdebug.ini \
    && rm -rf /tmp/pear

# install zip for Composer and entr for file-watching
# http://eradman.com/entrproject/
RUN apt-get update -yqq \
    && apt-get install -y \
        libzip-dev \
        zip \
        entr \
    && docker-php-ext-install zip \
    && rm -rf /var/lib/apt/lists/

# Enable inotify workaround for entr for macOS and WSL1
# https://github.com/eradman/entr#docker-and-wsl
ENV ENTR_INOTIFY_WORKAROUND=1

# Remove 10 MB /usr/src/php.tar.xz file. Unnecessary since we never update PHP without rebuilding.
# Ref: https://github.com/docker-library/php/issues/488
RUN rm /usr/src/php.tar.xz /usr/src/php.tar.xz.asc

# Get the latest release of phpunit from https://phar.phpunit.de/
# Bump this automatically with `npm run bump`
RUN curl -L https://phar.phpunit.de/phpunit-11.5.7.phar -o /usr/local/bin/phpunit \
    && chmod +x /usr/local/bin/phpunit

# For the time being, we're loading both Kint and Sage
# There was some sort of dispute where the original developer of Kint was
# removed from the project. Unclear what happened, or if one package is
# better than the other, but I've been using @raveren's version for a long
# time and want to keep an eye on it.
# https://github.com/php-sage/sage#-why-does-sage-look-so-much-like-kint-aka-why-does-this-have-so-few-stars

# Skeleton debug_loader
# Both Kint and Sage are required from this file since auto_prepend_file only accepts a single file
RUN echo '<?php' > /usr/local/lib/debug_loader.php

# Download and require Kint phar (update src/debug_loader.php)
RUN curl -L https://raw.githubusercontent.com/kint-php/kint/master/build/kint.phar -o /usr/local/lib/kint.phar \
    && chmod +x /usr/local/lib/kint.phar

# Download and require Sage phar
# NOTE: Was buggy, switching back to Kint
# RUN curl -L https://github.com/php-sage/sage/raw/main/sage.phar -o /usr/local/lib/sage.phar \
#     && chmod +x /usr/local/lib/sage.phar

COPY src/debug_loader.php /usr/local/lib

# Load debug libraries
RUN echo 'auto_prepend_file=/usr/local/lib/debug_loader.php' > /usr/local/etc/php/conf.d/debug.ini;

RUN echo '#!/bin/bash' > /usr/local/bin/watch \
    && echo "find {lib,src,test,tests} -name '*.php' | entr -c phpunit" >> /usr/local/bin/watch \
    && chmod +x /usr/local/bin/watch

USER 1000:1000

WORKDIR /app

CMD ["phpunit"]


# This should probably spin off into it's own repository
# By default, it will run PHPUnit in the current working directory (from docker compose)
# That's equivalent to running the image with `phpunit` as the command:
#
#    docker compose run test phpunit
#
# To watch files change the command to `watch` like this:
#
#    docker compose run test watch
#
#
# To see coverage in VSCode with the Coverage Gutters extension
# Be sure to add this to settings.json to remap the docker paths:
#    "coverage-gutters.remotePathResolve": ["/app/", "./"]


# The default working directory is /app. If the test root is in another directory,
# update that in the docker-compose file:
# ```yaml
#   test:
#     working_dir: /apt/tests
# ```
