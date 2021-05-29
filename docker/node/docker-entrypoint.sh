#!/bin/sh
set -e

envsubst < /usr/local/etc/php/conf.d/sylius-date.tmp > /usr/local/etc/php/conf.d/sylius-date.ini

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- node "$@"
fi

if [ "$1" = 'node' ] || [ "$1" = 'yarn' ]; then
	yarn install

	>&2 echo "Waiting for PHP to be ready..."
	until nc -z "$PHP_HOST" "$PHP_PORT"; do
		sleep 1
	done
fi

exec "$@"
