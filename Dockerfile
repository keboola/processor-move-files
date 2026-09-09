FROM php:7-cli

ARG COMPOSER_FLAGS="--prefer-dist --no-interaction"
ENV DEBIAN_FRONTEND noninteractive
ENV COMPOSER_ALLOW_SUPERUSER 1

WORKDIR /tmp/

COPY docker/composer-install.sh /tmp/composer-install.sh

# Debian 11 is out of security support: deb.debian.org still advertises bullseye-security packages whose
# .deb files have already been drained from the pool, so apt resolves versions it cannot download. The base
# image ships the matching snapshot.debian.org sources commented out - switch to those for a frozen and
# complete package set. The grep makes this fail loudly if the base image ever stops shipping them.
RUN grep -q '^# deb http://snapshot.debian.org' /etc/apt/sources.list \
    && sed -i -e 's|^deb |#deb |' -e 's|^# deb http://snapshot|deb http://snapshot|' /etc/apt/sources.list \
    && echo 'Acquire::Check-Valid-Until "0";' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get update && apt-get install -y --no-install-recommends \
        libzip-dev \
	    git \
        zlib1g-dev \
	&& rm -r /var/lib/apt/lists/* \
	&& docker-php-ext-install -j$(nproc) zip \
	&& chmod +x /tmp/composer-install.sh \
    && /tmp/composer-install.sh

WORKDIR /code/

## Composer - deps always cached unless changed
# First copy only composer files
COPY composer.* /code/
# Download dependencies, but don't run scripts or init autoloaders as the app is missing
RUN composer install $COMPOSER_FLAGS --no-scripts --no-autoloader
# copy rest of the app
COPY . /code/
# run normal composer - all deps are cached already
RUN composer install $COMPOSER_FLAGS

CMD ["php", "/code/main.php"]

