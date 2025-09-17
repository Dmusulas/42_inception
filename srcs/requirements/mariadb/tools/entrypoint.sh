#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

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

# Create the directory for the MariaDB socket file
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Check if the database data directory is empty (first run)
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Database data directory not found. Initializing..."

	# Read secrets into environment variables for use in this script
	file_env 'MYSQL_ROOT_PASSWORD'
	file_env 'MYSQL_PASSWORD'

	# Initialize MariaDB data directory
	mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

	# Start the server in the background
	mariadbd --user=mysql &
	pid="$!"

	# Wait for the server to be ready for connections
	while ! mysqladmin ping -h localhost --silent; do
		sleep 1
	done

	# Execute SQL commands to set up the database, users, and passwords
	mariadb -u root <<-EOSQL
		        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
		        DELETE FROM mysql.user WHERE User='';
		        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
		        DROP DATABASE IF EXISTS test;
		        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
		        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
		        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
		        FLUSH PRIVILEGES;
	EOSQL

	# Shut down the temporary server process that was running in the background
	if ! mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown; then
		echo >&2 'MariaDB shutdown failed.'
		exit 1
	fi
	# Wait for the background process to terminate
	wait "$pid"
	echo "Database initialization complete."
fi

echo "Starting MariaDB server."
# Start the main MariaDB server process in the foreground
exec mariadbd --user=mysql
