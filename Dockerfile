# https://hub.docker.com/_/php
# https://github.com/docker-library/docs/blob/master/php/README.md#supported-tags-and-respective-dockerfile-links
# FROM php:7.4-cli
FROM php:8.0.14-cli

# https://pecl.php.net/package/xdebug
RUN pecl install xdebug-3.1.2 \
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

# Remove 10 MB /usr/src/php.tar.xz file. Unnecesary since we never update PHP without rebuilding.
# Ref: https://github.com/docker-library/php/issues/488
RUN rm /usr/src/php.tar.xz /usr/src/php.tar.xz.asc

# install Composer
ENV COMPOSER_HOME="/usr/src/.composer"
ENV PATH="/usr/src/.composer/vendor/bin:${PATH}"
RUN curl -L https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer

# Global install PHPUnit
RUN composer global require phpunit/phpunit --prefer-dist

RUN echo '#!/bin/bash' > /usr/local/bin/watch \
    && echo "find {src,tests} -name '*.php' | entr phpunit" >> /usr/local/bin/watch \
    && chmod +x /usr/local/bin/watch

USER 1000:1000

WORKDIR /app

CMD ["phpunit"]


# This should probably spin off into it's own repository
# By default, it will run PHPUnit in the current workind directory (from docker compose)
# That's equavalent to running the image with `phpunit` as the command:
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
# dockerhub token: 7eed87ef-56ad-4d3d-9a1b-3c2b80ca1596
