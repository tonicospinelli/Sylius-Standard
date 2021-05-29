FROM sylius-standard_phpfpm as sylius_build

ARG SYLIUS_WORKSPACE_PATH
ARG COMPOSER_MEMORY_LIMIT=-1

RUN mkdir -p "${SYLIUS_WORKSPACE_PATH}"
WORKDIR "$SYLIUS_WORKSPACE_PATH"

COPY ../../composer.* .
COPY symfony.lock .
COPY ../symfony.lock .
COPY ../../symfony.lock .
COPY ../../../symfony.lock .
RUN pwd;sleep 5;
RUN ls -l;sleep 5;
RUN composer install --prefer-dist;

FROM sylius_build as sylius_app

ARG SYLIUS_WORKSPACE_PATH
ARG DATABASE_HOST
ARG DATABASE_PORT

COPY wait-for-it.sh /usr/bin/wait-for-it

RUN chmod +x /usr/bin/wait-for-it

WORKDIR "$SYLIUS_WORKSPACE_PATH"

CMD wait-for-it "$DATABASE_HOST:$DATABASE_PORT" -- bin/console doctrine:migrations:migrate ;  php-fpm 

EXPOSE 9000