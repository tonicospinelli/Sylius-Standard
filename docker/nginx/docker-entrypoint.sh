#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- node "$@"
fi

if [ "$1" = 'node' ] || [ "$1" = 'yarn' ]; then
	yarn install

	>&2 echo "Waiting for PHP to be ready..."
	until nc -z "$PHPFPM_HOST" "$PHPFPM_PORT"; do
		sleep 1
	done
fi

exec "$@"
