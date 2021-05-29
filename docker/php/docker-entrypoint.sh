#!/bin/sh
set -e

envsubst < /usr/local/etc/php/conf.d/sylius-date.tmp > /usr/local/etc/php/conf.d/sylius-date.ini
envsubst < /usr/local/etc/php-fpm.d/zzz-sylius.tmp > /usr/local/etc/php-fpm.d/zzz-sylius.conf

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'bin/console' ]; then
	until bin/console doctrine:query:sql "select 1" >/dev/null 2>&1; do
	    (>&2 echo "Waiting for database to be ready...")
		sleep 1
	done
    bin/console doctrine:migrations:migrate --no-interaction
fi

exec docker-php-entrypoint "$@"
