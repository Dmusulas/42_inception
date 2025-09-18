#!/bin/bash

set -e

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

# Ensure runtime directories exist with correct permissions
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Only initialize if the data directory is empty
if [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "Database data directory is empty. Initializing..."

    file_env 'MYSQL_ROOT_PASSWORD'
    file_env 'MYSQL_PASSWORD'

    if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ]; then
        echo >&2 "Error: Required environment variables are not set."
        echo >&2 "Please set MYSQL_ROOT_PASSWORD, MYSQL_USER, MYSQL_PASSWORD, and MYSQL_DATABASE."
        exit 1
    fi

    echo "Running mariadb-install-db..."
    gosu mysql mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

    echo "Starting temporary MariaDB server..."
    gosu mysql mariadbd --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    pid="$!"

    echo "Waiting for MariaDB server to be ready..."
    for i in {30..0}; do
        if mariadb-admin --socket=/run/mysqld/mysqld.sock ping &> /dev/null; then
            break
        fi
        echo "MariaDB server not yet available, waiting..."
        sleep 1
    done

    if [ "$i" = 0 ]; then
        echo >&2 'MariaDB setup failed: server did not start.'
        exit 1
    fi

    echo "Configuring database..."
    mariadb --socket=/run/mysqld/mysqld.sock -u root <<-EOSQL
        -- Set root password
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        -- Grant privileges and flush
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    echo "Shutting down temporary server..."
    if ! mariadb-admin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown; then
        echo >&2 'MariaDB shutdown failed.'
        kill -s TERM "$pid"
        wait "$pid"
    fi
    wait "$pid"
    echo "Database initialization complete. 🚀"
fi

echo "Handing over to the main MariaDB process..."
exec gosu mysql "$@"