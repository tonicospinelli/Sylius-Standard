# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/compose/compose-file/#target

ARG PHP_VERSION=${PHP_VERSION:-7.4}

FROM php:${PHP_VERSION}-fpm-alpine AS phpfpm_base

ENV PHP_EXTENSION_APCU_VERSION "${PHP_EXTENSION_APCU_VERSION:-5.1.17}"

# persistent / runtime deps
RUN apk add --no-cache \
        acl \
        file \
        gettext \
        git \
        mariadb-client \
       $PHPIZE_DEPS \
    ;

RUN apk add --no-cache --virtual .build-deps \
        coreutils \
        freetype-dev \
        icu-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libtool \
        libwebp-dev \
        libzip-dev \
        mariadb-dev \
        zlib-dev \
    ;

RUN docker-php-ext-configure gd \
        --with-jpeg=/usr/include/ \
        --with-webp=/usr/include \
        --with-freetype=/usr/include/

RUN docker-php-ext-install -j$(nproc) \
        exif \
        gd \
        intl \
        pdo_mysql \
        zip \
    ;
RUN pecl install \
        apcu-${PHP_EXTENSION_APCU_VERSION} \
    ; \
    pecl clear-cache;

RUN docker-php-ext-enable \
        apcu \
        opcache \
    ;

RUN runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache --virtual .sylius-phpexts-rundeps $runDeps; \
    apk del .build-deps

FROM phpfpm_base AS phpfpm_config

ENV PHP_DATE_TIMEZONE "${PHP_DATE_TIMEZONE}"
ENV PHPFPM_LISTEN "${PHPFPM_LISTEN}"
ENV PHPFPM_LOG_LEVEL "${PHPFPM_LOG_LEVEL}"
ENV PHP_MEMORY_LIMIT "${PHP_MEMORY_LIMIT}"
ENV PHPFPM_PM "${PHPFPM_PM}"
ENV PHPFPM_PM_MAX_CHILDREN "${PHPFPM_PM_MAX_CHILDREN}"
ENV PHPFPM_PM_MIN_SPARE_SERVERS "${PHPFPM_PM_MIN_SPARE_SERVERS}"
ENV PHPFPM_PM_MAX_REQUESTS "${PHPFPM_PM_MAX_REQUESTS}"
ENV PHPFPM_PM_MAX_SPARE_SERVERS "${PHPFPM_PM_MAX_SPARE_SERVERS}"
ENV PHPFPM_PM_START_SERVERS "${PHPFPM_PM_START_SERVERS}"

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY conf.d/* /usr/local/etc/php/conf.d
COPY php-fpm.d/* /usr/local/etc/php-fpm.d

RUN composer global require "symfony/flex" --prefer-dist --no-progress --classmap-authoritative

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]
