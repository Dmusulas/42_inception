#!/bin/bash

set -e

# This script runs as the root user to handle setup.

# Function to read secrets from files
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

# Ensure runtime directories exist and have correct permissions
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Initialize database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Database data directory not found. Initializing..."

	file_env 'MYSQL_ROOT_PASSWORD'
	file_env 'MYSQL_PASSWORD'

	# Run the installation as the mysql user
	gosu mysql mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

	# Start a temporary server as the mysql user
	gosu mysql mariadbd --user=mysql --skip-networking &
	pid="$!"

	# Wait for the local socket file to appear
	for i in {30..0}; do
		if [ -S /run/mysqld/mysqld.sock ]; then
			break
		fi
		echo 'MariaDB socket not found, waiting...'
		sleep 1
	done
	if [ "$i" = 0 ]; then
		echo >&2 'MariaDB setup failed: socket not created.'
		exit 1
	fi

	# Configure the database by running the client AS ROOT.
	# This will succeed because of unix_socket authentication.
	mariadb --socket=/run/mysqld/mysqld.sock -u root <<-EOSQL
		        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
		        DROP DATABASE IF EXISTS \`${MYSQL_DATABASE}\`;
		        CREATE DATABASE \`${MYSQL_DATABASE}\`;
		        DROP USER IF EXISTS '${MYSQL_USER}'@'%';
		        CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
		        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
		        FLUSH PRIVILEGES;
	EOSQL

	# Shut down the temporary server
	if ! mariadb-admin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown; then
		echo >&2 'MariaDB shutdown failed.'
		exit 1
	fi
	wait "$pid"
	echo "Database initialization complete."
fi

echo "Starting MariaDB server as mysql user."
# Start the final server process as the mysql user
exec gosu mysql mariadbd
