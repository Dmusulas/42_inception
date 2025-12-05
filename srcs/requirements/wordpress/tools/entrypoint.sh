#!/bin/bash

# Function to read a secret from a file and export it as an environment variable
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val=""
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(<"${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

# Read all password secrets into environment variables
file_env 'MYSQL_PASSWORD'
file_env 'WP_ADMIN_PASSWORD'
file_env 'WP_USER_PASSWORD'

if [ -f "wp-config.php" ]; then
	echo "WordPress is already configured."
else
	echo "Configuring WordPress for the first time..."

	wp core download --allow-root

	wp config create --allow-root \
		--dbname="$MYSQL_DATABASE" \
		--dbuser="$MYSQL_USER" \
		--dbpass="$MYSQL_PASSWORD" \
		--dbhost="mariadb:3306" \
		--dbcharset="utf8" \
		--dbcollate="utf8_general_ci"

	wp core install --allow-root \
		--url="$DOMAIN_NAME" \
		--title="My WordPress Site" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--skip-email

	# MODIFIED: Uses the WP_USER_ROLE env var, defaults to 'author' if not set
	wp user create --allow-root \
		"$WP_USER_LOGIN" \
		"$WP_USER_EMAIL" \
		--role=${WP_USER_ROLE:-author} \
		--user_pass="$WP_USER_PASSWORD"

	chown -R www-data:www-data /var/www/html

	echo "WordPress configured successfully."
fi
mkdir -p /run/php
exec "$@"
